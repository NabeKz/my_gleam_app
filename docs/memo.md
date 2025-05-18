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
