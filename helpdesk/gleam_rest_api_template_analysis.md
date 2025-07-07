# Gleam REST API サーバー プロジェクト雛形 分析結果

## 概要

このドキュメントは、現在のGleamアプリケーションから抽出したREST APIサーバーのプロジェクト雛形として利用可能な構造パターンの分析結果をまとめたものです。

## 1. 全体的なアーキテクチャパターン

### Clean Architecture の採用
- **Domain Layer**: `src/app/features/*/domain.gleam`
- **Use Case Layer**: `src/app/features/*/usecase/` および `*_usecase.gleam`
- **Adapter Layer**: `src/app/adaptor/`
- **Infrastructure Layer**: `src/app/features/*/infra/`

### 特徴
- 機能単位（feature-based）のディレクトリ構成
- 依存性注入による実装の切り替え
- 複数のストレージバックエンド対応
- テスト容易性を考慮した設計

## 2. ディレクトリ構造テンプレート

```
project_root/
├── src/
│   ├── app.gleam                          # エントリーポイント
│   ├── app/
│   │   ├── context.gleam                  # 依存性注入コンテナ
│   │   ├── router.gleam                   # ルーティング分岐
│   │   ├── router/
│   │   │   ├── api_router.gleam          # API エンドポイント
│   │   │   └── web_router.gleam          # Web ページ（オプション）
│   │   ├── adaptor/
│   │   │   ├── api/                      # API コントローラー
│   │   │   │   ├── ticket_controller.gleam
│   │   │   │   └── user_controller.gleam
│   │   │   └── pages/                    # Web ページ（オプション）
│   │   │       ├── auth.gleam
│   │   │       ├── ticket.gleam
│   │   │       └── user/
│   │   ├── features/                     # 機能単位の実装
│   │   │   ├── auth/
│   │   │   ├── ticket/
│   │   │   └── user/
│   │   └── shared/                       # アプリケーション共通処理
│   │       ├── validation/
│   │       │   └── validator.gleam      # バリデーション
│   │       ├── serialization/
│   │       │   └── deserializer.gleam   # JSON シリアライゼーション
│   │       └── utilities/
│   │           └── parser.gleam         # パース機能
│   └── lib/                              # 腐敗防止層（外部ライブラリラッパー）
│       ├── {database_wrapper}.gleam      # 例: db.gleam（データベース接続）
│       ├── {storage_wrapper}.gleam       # 例: ets.gleam（ETS抽象化）
│       ├── {http_wrapper}.gleam          # 例: web.gleam（HTTP ヘルパー）
│       ├── {utility_wrapper}.gleam       # 例: time.gleam, uuid.gleam等
│       └── ffi/                          # FFI関連（必要に応じて）
│           └── {external}.{ext}          # 例: calendar.mjs
├── test/
│   └── {feature}/
│       ├── {test_type}_test.gleam        # 例: domain_test.gleam, usecase_test.gleam等
│       └── fixture.gleam                 # テストデータ・ヘルパー
├── gleam.toml                            # プロジェクト設定
├── mise.toml                             # 開発環境設定
├── atlas.hcl                             # DB マイグレーション設定
└── README.md
```

## 3. 機能（Feature）の標準構造

### 基本的な機能構造パターン
```
src/app/features/{feature_name}/
├── domain.gleam                          # エンティティ・VO・ビジネスロジック
├── domain/                               # ドメイン固有の型やヘルパー
│   ├── {entity}_id.gleam
│   └── {entity}_status.gleam
├── {feature}_usecase.gleam               # ユースケース関数のエクスポート
├── usecase/                              # CQRS分離によるユースケース実装
│   ├── {entity}_command_usecase.gleam   # 書き込み操作（create, update, delete）
│   ├── {entity}_query_usecase.gleam     # 読み取り操作（list, search）
│   └── {entity}_command_common.gleam    # 共通の型定義・decode処理
└── infra/                                # インフラストラクチャ層
    ├── {entity}_repository_on_ets.gleam    # 開発・テスト用（高速）
    └── {entity}_repository_on_sqlite.gleam # 本番用（永続化）
```

### 標準的な型定義パターン
```gleam
// domain.gleam の標準的な型定義
pub type Entity {
  Entity(id: EntityId, field1: String, field2: Status, ...)
}

pub type EntityWriteModel {
  EntityWriteModel(field1: String, field2: Status, ...)
}

// ユースケース関数の型定義
pub type SearchEntity = fn(SearchParams) -> List(Entity)         # 検索条件付き一覧取得
pub type GetAllEntity = fn() -> List(Entity)                     # 全件取得
pub type GetEntity = fn(EntityId) -> Result(Entity, String)      # 単体取得
pub type CreateEntity = fn(EntityWriteModel) -> EntityId         # 作成
pub type UpdateEntity = fn(Entity) -> EntityId                   # 更新
pub type DeleteEntity = fn(EntityId) -> Result(Nil, String)      # 削除
```

## 4. CQRS分離によるユースケースパターン

### Command/Query分離の構造
- **Command**: データ変更操作（create, update, delete）
- **Query**: データ取得操作（list, search）
- **Common**: 共通の型定義とヘルパー関数

### 各ファイルの責務
- **{entity}_command_usecase.gleam**: 約90行
  - エンティティの作成、更新、削除
  - 入力データの変換・バリデーション
  - ビジネスルールの適用
- **{entity}_query_usecase.gleam**: 約100行
  - エンティティの一覧取得、単体取得
  - 検索条件の処理
  - 出力データの変換
- **{entity}_command_common.gleam**: 約30行
  - 共通の型定義（DTO、エラー型）
  - decode処理
  - バリデーション関数

### CQRS分離の利点
- 読み取りと書き込みの最適化が独立して可能
- 各ファイルが適切なサイズに収まる
- コードの重複を削減
- 単一責任の原則を維持

## 5. 設定ファイル群のテンプレート

### gleam.toml の標準構成
```toml
name = "project_name"
version = "1.0.0"
description = "project_description"
licences = ["MIT"]
extra_applications = ["ssl"]

[dependencies]
gleam_stdlib = ">= 0.34.0 and < 2.0.0"
wisp = ">= 1.6.0 and < 2.0.0"          # Web framework
mist = ">= 4.0.7 and < 5.0.0"          # HTTP server
gleam_http = ">= 4.0.0 and < 5.0.0"    # HTTP utilities
gleam_json = ">= 2.3.0 and < 3.0.0"    # JSON handling
gleam_erlang = ">= 0.34.0 and < 1.0.0" # Erlang interop
sqlight = ">= 1.0.1 and < 2.0.0"       # SQLite driver
gleam_otp = ">= 0.16.1 and < 1.0.0"    # OTP utilities
gluid = ">= 1.1.0 and < 2.0.0"         # UUID generation

[dev-dependencies]
gleeunit = ">= 1.0.0 and < 2.0.0"      # Testing framework
```

### mise.toml の標準構成
```toml
[tools]
erlang = "latest"
gleam = "latest"
node = "latest"
rebar = "latest"

[tasks.serve]
run = """
  watchexec --restart --clear --wrap-process=session --stop-signal \
  SIGTERM --exts gleam --watch src/ -- "gleam run"
"""
description = "Start development server with file watching"

[tasks.migrate]
run = """
  rm -f database.sqlite3
  atlas migrate apply --env dev
"""
description = "Apply database migrations using Atlas"
```

## 6. 依存性注入パターン

### Context による依存性管理
```gleam
pub type Context {
  Context(
    auth: Auth,
    user: user.UserRepository,
    ticket: ticket_controller.Resolver,
    // 他の機能を追加...
  )
}

// 実装の切り替え
pub fn production(db: db.Conn) -> Context   # SQLite 実装（本番環境）
pub fn development() -> Context             # ETS 実装（開発・テスト環境）
```

### 2つのストレージ実装パターン
- **ETS実装**: 開発・テスト環境用
  - 高速なアクセス
  - セットアップが不要
  - プロセス内永続化
- **SQLite実装**: 本番環境用
  - 完全な永続化
  - 複雑なクエリ対応
  - ACID特性の保証

## 7. API コントローラーパターン

### 標準的なコントローラー構造
```gleam
pub type Resolver {
  Resolver(
    search_entity: SearchEntity,
    get_all_entity: GetAllEntity,
    get_entity: GetEntity,
    create_entity: CreateEntity,
    update_entity: UpdateEntity,
    delete_entity: DeleteEntity,
  )
}

pub fn routes(path: List(String), req: Request, resolver: Resolver) -> Response {
  case path, req.method {
    [], http.Get -> list(req, resolver.search_entity, resolver.get_all_entity)
    [], http.Post -> post(req, resolver.create_entity)
    [id], http.Get -> get_one(id, resolver.get_entity)
    [id], http.Delete -> delete(id, resolver.delete_entity)
    _, _ -> http_core.not_found()
  }
}
```

## 8. 責務分離パターン

### 腐敗防止層（lib/）
外部ライブラリのラッパーを配置。プロジェクトに応じて以下のような例が考えられる：
- **データベース接続の抽象化** - 例: `db.gleam`（SQLite、PostgreSQL等）
- **ストレージ操作の抽象化** - 例: `ets.gleam`（ETS、Redis等）  
- **HTTP操作の抽象化** - 例: `web.gleam`（Wisp、その他のフレームワーク）
- **ユーティリティ系の抽象化** - 例: `time.gleam`, `uuid.gleam`, `crypto.gleam`等
- **FFI関連** - 例: `ffi/calendar.mjs`（必要に応じて分離）

### アプリケーション共通処理（app/shared/）
- **validation/**: モナディックなバリデーション
- **serialization/**: JSON レスポンスの標準化
- **utilities/**: 汎用的なパーサーとヘルパー

### 特徴
- **明確な責務分離**: 外部ライブラリラッパーとアプリケーション共通処理を分離
- **依存関係の整理**: app/shared/ → lib/ の一方向依存
- **保守性の向上**: 外部ライブラリ変更の影響を局所化
- **テスト容易性**: 各層の境界が明確でモック化が容易

## 9. テスト戦略パターン

### テスト構造
```
test/
├── {feature}/
│   ├── {test_type}_test.gleam           # 例: domain_test.gleam, usecase_test.gleam等
│   └── fixture.gleam                    # テストデータ・ヘルパー関数
└── {feature}_test.gleam                 # 例: 統合テスト（必要に応じて）
```

### テスト戦略の例
プロジェクトのニーズに応じて以下のようなテスト粒度が考えられる：
- **ドメインロジックテスト** - 例: `domain_test.gleam`
- **ユースケーステスト** - 例: `usecase_test.gleam`, `command_test.gleam`, `query_test.gleam`
- **統合テスト** - 例: `{feature}_test.gleam`
- **テストフィクスチャ** - `fixture.gleam`（共通のテストデータとヘルパー関数）
- **モック・スタブ** - 依存関係の分離（必要に応じて）

## 10. 汎用化のメリット

### 開発効率の向上
- 一貫したプロジェクト構造
- 新機能追加時の迷いの軽減
- コードレビューの効率化

### 保守性の向上
- Clean Architectureに基づく設計
- 機能単位の独立性
- テスト容易性の確保

### 柔軟性の確保
- 2つのストレージ実装による環境対応
- 依存性注入による実装切り替え
- 開発から本番への段階的な移行

## 11. 推奨される使用方法

### 新規プロジェクト開始時
1. 基本的なディレクトリ構造を設定
2. 設定ファイル群を調整
3. 共通ライブラリを配置
4. 最初の機能を実装

### 機能追加時
1. 機能単位のディレクトリを作成
2. CQRS分離によるユースケースを実装
3. ETS・SQLite両方のストレージ実装を用意
4. Command/Query別のテストを作成

### 既存プロジェクトの改善時
1. 段階的な構造の移行
2. 機能単位での分離
3. テストの追加
4. 依存性の整理

## まとめ

この分析により、Gleamを使用したREST APIサーバーの開発において、保守性が高く、テスト容易で、拡張性のあるプロジェクト構造のパターンが明確になりました。これらのパターンを活用することで、効率的で品質の高いAPI開発が可能になります。