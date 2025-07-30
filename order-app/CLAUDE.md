# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Gleam イベントソーシング実装ガイド

## プロジェクト概要
- **目的**: 関数型ドメインモデリングを参考にしたイベントソーシングの学習
- **言語**: Gleam
- **ドメイン**: ship_order（注文配送システム）
- **参考書籍**: "Domain Modeling Made Functional" by Scott Wlaschin

## 開発コマンド

### 基本コマンド
```bash
gleam run          # プロジェクトを実行
gleam test         # 全てのテストを実行
gleam build        # プロジェクトをビルド
gleam format       # コードをフォーマット
gleam check        # 型チェックを実行
```

### 依存関係管理
```bash
gleam deps download    # 依存関係をダウンロード
gleam deps update      # 依存関係を更新
```

### その他の便利なコマンド
```bash
gleam docs build      # ドキュメントを生成
gleam shell           # REPL を起動
```

## アーキテクチャ決定

### 1. ディレクトリ構造（階層化アプローチ）
```
order_processing_system/
├── src/
│   └── order_processing/
│       ├── core/                    # 下位層：基盤ドメインサービス
│       │   ├── pricing/             # 価格計算の責務
│       │   └── shared/              # 共通値オブジェクト
│       │
│       ├── features/                # 上位層：ビジネス機能
│       │   └── ship_order/          # 注文配送機能
│       │       ├── domain/
│       │       │   ├── core/        # Level 0: 基礎要素
│       │       │   │   ├── events.gleam
│       │       │   │   ├── value_objects.gleam
│       │       │   │   └── aggregate.gleam
│       │       │   └── logic/       # Level 1: ビジネスロジック
│       │       │       ├── commands.gleam
│       │       │       └── command_handlers.gleam
│       │       ├── application/
│       │       │   └── order_service.gleam
│       │       └── infrastructure/
│       │           └── event_store.gleam
│       │
│       └── app.gleam
```

### 2. 依存関係のルール
- **許可される依存**: 上位層 → 下位層
- **features層** → **core層** （OK）
- **logic/** → **core/** （OK）
- **application/** → **domain/logic/**, **domain/core/** （OK）
- **infrastructure/** → **domain/core/** （OK）

### 3. 段階的実装アプローチ
- **Phase 1**: 階層化で開始（シンプル）
- **Phase 2**: 副作用をイベントで分離（必要に応じて）
- **Phase 3**: 複雑な要件でSagaの検討（将来的に）

## 実装仕様

### 実装順序
1. `domain/core/events.gleam` - イベント定義
2. `domain/core/value_objects.gleam` - 値オブジェクト
3. `domain/core/aggregate.gleam` - Order状態 + apply_event
4. `domain/logic/commands.gleam` - コマンド定義
5. `domain/logic/command_handlers.gleam` - ハンドラー + バリデーション
6. `application/order_service.gleam` - アプリケーションサービス
7. `infrastructure/event_store.gleam` - イベントストア（インメモリ）

### 各ファイルの責務

#### `domain/core/events.gleam`
```gleam
// 過去に起こった事実（不変）
pub type OrderEvent {
  OrderPlaced(order_id: String, customer_info: CustomerInfo, ...)
  OrderValidated(order_id: String, ...)
  OrderCancelled(order_id: String, reason: String, ...)
  OrderShipped(order_id: String, tracking_number: String, ...)
}
```

#### `domain/core/value_objects.gleam`
```gleam
// 値オブジェクト：Make Illegal States Unrepresentable
pub opaque type EmailAddress { EmailAddress(String) }
pub opaque type Price { Price(Int) }
pub type CustomerInfo { CustomerInfo(name: String, email: EmailAddress) }
```

#### `domain/core/aggregate.gleam`
```gleam
pub type Order {
  Order(id: String, status: OrderStatus, version: Int, ...)
}

// イベントから状態を再構築
pub fn apply_event(order: Order, event: OrderEvent) -> Order
pub fn apply_events(order: Order, events: List(OrderEvent)) -> Order
```

#### `domain/logic/commands.gleam`
```gleam
pub type OrderCommand {
  PlaceOrder(order_id: String, customer_info: CustomerInfo, ...)
  ValidateOrder(order_id: String)
  CancelOrder(order_id: String, reason: String)
}
```

#### `domain/logic/command_handlers.gleam`
```gleam
pub type CommandResult {
  Success(events: List(OrderEvent))
  Failure(error: String)  
}

// Railway Oriented Programming
pub fn handle_place_order(
  current_order: Option(Order),
  command: PlaceOrderCommand
) -> CommandResult

// バリデーション関数も同じファイルに統合
fn validate_customer_info(customer: CustomerInfo) -> Result(Nil, String)
fn validate_order_lines(lines: List(OrderLine)) -> Result(Nil, String)
```

#### `infrastructure/event_store.gleam`
```gleam
// インメモリイベントストア（学習用）
pub type EventStore { EventStore(events: Dict(String, List(StoredEvent))) }

pub fn save_events(store: EventStore, aggregate_id: String, events: List(OrderEvent), expected_version: Int) -> Result(EventStore, String)
pub fn get_events(store: EventStore, aggregate_id: String) -> Result(List(OrderEvent), String)
```

## 設計原則

### 関数型ドメインモデリングのパターン
1. **型駆動設計**: Gleamの型システムを最大活用
2. **Make Illegal States Unrepresentable**: 不正な状態を型で排除
3. **Railway Oriented Programming**: Result型でエラーハンドリング
4. **Pure Functions**: 副作用のない関数でビジネスロジック
5. **Composition**: 小さな関数を組み合わせて複雑なワークフローを構築

### イベントソーシングの核心概念
1. **Events = Truth**: イベントが唯一の真実（Single Source of Truth）
2. **Aggregate = Current State**: アグリゲートは計算された結果
3. **Command → Event**: コマンドはイベントを生成するための意図
4. **Event Replay**: イベントを再生すれば任意の時点の状態が復元可能
5. **Append Only**: イベントは追記のみ（削除・更新なし）

## テスト

### テストフレームワーク
- **gleeunit**: Gleamの標準テストフレームワーク
- テスト関数は `_test` で終わる命名規則

### テスト戦略
1. **domain/core層**: 純粋関数の単体テスト
2. **domain/logic層**: コマンドハンドラーの単体テスト
3. **application層**: 統合テスト
4. **各段階でテストを充実させる**

### テストの実行
```bash
gleam test                    # 全テストを実行
gleam test --target erlang    # Erlangターゲットでテスト実行
gleam test --target javascript # JavaScriptターゲットでテスト実行
```

## 依存関係

### 主要な依存関係
- **gleam_stdlib**: Gleam標準ライブラリ
- **gleam_time**: 時間処理
- **gleam_json**: JSON処理
- **gleam_otp**: OTPパターン（アクター、スーパーバイザーなど）
- **gluid**: UUID生成

## ツール管理
- **mise**: 開発環境ツール管理（Erlang、Gleam、rebarを管理）
- インストール: `mise install`
- 環境切り替え: `mise use`

## 外部システム連携
- **学習用のため外部システムとの実際の連携はなし**
- **必要に応じてモック実装**（ランダムで成功/失敗を返すなど）

## 実装時の注意点
1. **価格計算は階層化アプローチ**: `core/pricing`サービスを直接呼び出し
2. **バリデーションはcommand_handlers.gleamに統合**
3. **最初はインメモリEvent Store**、後でファイル永続化に変更可能
4. **型安全性を重視**: コンパイル時にできるだけ多くのエラーを検出

## 次のステップ
1. `domain/core/events.gleam`からイベント型の定義を開始
2. ship_orderドメインで発生する「事実」を洗い出す
3. 関数型アプローチでtype-safe な実装を進める

## 参考
- Domain Modeling Made Functional (Scott Wlaschin)
- イベントソーシングパターン
- [Gleam公式ドキュメント](https://gleam.run/)