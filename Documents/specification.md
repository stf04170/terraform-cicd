## IaCを用いたAPIサーバの構築

### 学習の目的
- IaC(Terraform)を用いたデータ基盤構築を経験する
- AWSのDBとして未経験のAurora/PostgreSQLを経験する
- 実務を想定し、API Gateway, Secrets Managerといったセキュアな基盤を構築する


### システムの目的
- Webエンジニアといった開発者向けのAPIサーバを構築し、イベントの取得（READ操作）をサポートする
  - 後々、追加・更新・削除（CRUD操作）も追加したい
- 扱うデータはイベントプラットフォームのデータ(イベント/ユーザー/申込み情報)を想定

### データ
- 入力：
  - イベントプラットフォームのデータ(イベント/ユーザー/申込み情報)を想定
  - データ構造は[DB構造](#db構造)を参照
  - IaCの学習がメインのテーマなので序盤は手動登録
  - 後々はAPIのPostで登録できるような基盤に
- 出力：
  1. イベントのテータそのもの
  2. ログデータから得られる集計値（例: イベント別参加者情報、カテゴリ別イベント情報など）→ [API仕様書](#API仕様)

### 技術仕様
- アプリケーションはHTTPSで保護され、Secrets Managerから取得したDB接続情報を使用してセキュアに接続される

### 扱う技術
| 技術                   | 用途                           |
| ---------------------- | ------------------------------ |
| Terraform              | IaC                            |
| AWS Aurora(PostgreSQL) | DB                             |
| AWS Lambda             | アプリケーションサーバ         |
| AWS API Gateway        | セキュアなエンドポイント展開   |
| AWS Secrets Manager    | 機密情報(DB認証情報など)の管理 |


### 可能であれば
- GitHub ActionsによるCI/CDも実装したい
- 環境別(STG/本番)のデプロイも意識したい


### DB構造

#### 1. events テーブル

| カラム名      | データ型      | 説明                                     |
| ------------- | ------------- | ---------------------------------------- |
| event_id      | UUID          | イベントの一意識別子（主キー）           |
| name          | VARCHAR(255)  | イベント名                               |
| description   | TEXT          | イベントの詳細説明                       |
| location      | VARCHAR(255)  | イベントの開催場所                       |
| start_time    | DATETIME      | イベントの開始日時                       |
| end_time      | DATETIME      | イベントの終了日時                       |
| organizer     | VARCHAR(255)  | 主催者名                                 |
| category      | VARCHAR(100)  | イベントのカテゴリ（例：音楽、スポーツ） |
| created_at    | DATETIME      | データが作成された日時                   |
| updated_at    | DATETIME      | データが最後に更新された日時             |
| price         | DECIMAL(10,2) | イベント参加費用（任意）                 |
| max_attendees | INTEGER       | 最大参加者数                             |
| url           | VARCHAR(255)  | イベントの詳細URL（任意）                |

#### 2. users テーブル

| カラム名      | データ型     | 説明                         |
| ------------- | ------------ | ---------------------------- |
| user_id       | UUID         | ユーザの一意識別子（主キー） |
| name          | VARCHAR(255) | ユーザ名                     |
| email         | VARCHAR(255) | ユーザのメールアドレス       |
| password_hash | VARCHAR(255) | パスワードのハッシュ         |
| created_at    | DATETIME     | データが作成された日時       |
| updated_at    | DATETIME     | データが最後に更新された日時 |
| phone_number  | VARCHAR(15)  | ユーザの電話番号（任意）     |

#### 3. purchases テーブル（中間テーブル）

| カラム名        | データ型      | 説明                             |
| --------------- | ------------- | -------------------------------- |
| purchase_id     | UUID          | 購入の一意識別子（主キー）       |
| user_id         | UUID          | 購入したユーザのID（外部キー）   |
| event_id        | UUID          | 購入したイベントのID（外部キー） |
| purchase_time   | DATETIME      | 購入が行われた日時               |
| ticket_quantity | INTEGER       | 購入したチケットの数量           |
| total_price     | DECIMAL(10,2) | 合計金額                         |


### API仕様
