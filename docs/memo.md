# hexagonal architecture

- adaptor

  - UI
  - DB
  - Email
  - Logging

- アプリケーションで完結できないロジック

  - 外部に依存するため実行時例外が発生しやすい

- port
  - 外部と通信するための場所
  - ユーザ側のポートとデータベース側のポートがある
- adaptor
  - port 用のデータ変換が責務

# onion architecture

# Actorパターンの学習メモ

## Actorの基本概念

**Actor = 超小型REST APIサーバー**
- HTTPリクエストを待つ → メッセージを待つ
- GET /users → GetAll メッセージ  
- POST /users → Push メッセージ
- JSON レスポンス → メッセージで返信
- ポート番号で識別 → Subject/PIDで識別

## 関数型と状態管理の両立

**「関数は不変、プロセスは可変」**
- 各`handle_message`は純粋関数（不変）
- プロセス全体では履歴を積み上げて状態継続
- `old_state → function → new_state → function → newer_state...`

## Actorの通信フロー

```
process.call(message) → handle_message(message, state) → process.send(reply)
```

1. **process.call**: メッセージを送信して結果を待機
2. **handle_message**: メッセージに応じた処理を実行  
3. **process.send**: 処理結果を返信
4. **actor.continue**: 次の状態でループ継続

## メッセージの種類

- **同期通信**: `Push(item, Subject(Nil))` - 結果が必要
- **非同期通信**: `LogInfo(String)` - Fire-and-forget

## メモリ管理

- Gleamには個別プロセス容量制限なし
- **自主制限**で対応: N件を超えたら古いデータを削除
- **履歴の積み上げ**なので放置するとメモリ不足でクラッシュ

## 他の技術との共通点

### 設計パターンの類似性
- **React Reducer**: `(state, action) → state`
- **Elm Update**: `(msg, model) → model` 
- **Actor**: `(msg, state) → Next(msg, state)`

### Event Sourcingとの共通点
- **Process**: 状態変化を履歴として積み上げ
- **Event Sourcing**: イベントを履歴として積み上げ
- どちらも再現可能性と監査ログの利点

### クラウドアーキテクチャとの共通思想
- **障害の隔離**: 1つの障害が全体に影響しない
- **非同期通信**: 直接的な状態共有を避ける
- **自動復旧**: 障害を検知して自動復旧
- **独立性**: 各コンポーネントが独立して動作

## BEAMの特徴

**「Let it crash + Supervisor」**
- エラーハンドリングを頑張らない
- クラッシュしたら潔く死ぬ
- Supervisorが自動で蘇生
- アプリ起動時に自動的にSupervision Tree構築

## Mock Repository実装のポイント

```gleam
// 状態 + インクリメントID + 容量制限を保持
MockRepoState(items: List(a), next_id: Int, max_items: Int)

// 容量制限の実装
case list.length(state) >= max_items {
  True -> [item_with_id, ..list.take(state, max_items - 1)]
  False -> [item_with_id, ..state]
}
```

JavaScriptの`Array.push()`と同じ感覚で、可変データとして使える。
