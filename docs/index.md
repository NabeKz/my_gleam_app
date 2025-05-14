1. 📚 書籍レビュー管理 API（Book Review API）

- 書籍一覧、レビュー投稿、平均スコア表示など

- 認証なしでも使えるパブリックな API としても成り立つ

- エンティティ：Book, Review, User

2. 🧾 経費精算アプリ API（Expense Tracker）

- ユーザーが経費を登録、カテゴリ別に集計

- 通貨、日付、カテゴリなどの型が明確に分かれる

- エンティティ：User, Expense, Category

3. 🎫 サポートチケット管理 API（Helpdesk API）

- ユーザーがチケットを登録して、スタッフが対応

- ステータス管理（open/closed/waiting）や優先度などの列挙型が活きる

- エンティティ：User, Ticket, Response

4. 🍽 飲食店の注文 API（Restaurant Ordering）

- 注文、メニュー、テーブルの管理

- ステートフルな状態管理（注文中 → 配膳済みなど）があるので、Gleam の ADT が活きる

- エンティティ：Table, Order, Item, Staff

- <https://github.com/TahaSh/gleam-todo-web-app?tab=readme-ov-file>

5. 図書館 API

- 貸出

- 検索

- 予約

- 催促
