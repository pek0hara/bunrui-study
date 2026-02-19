# 検定学習アプリ

FlutterとCloudflare Workers + D1で構築された検定学習アプリケーションです。

## 技術スタック

- **フロントエンド**: Flutter 3.9.2+（Flutter Web としてデプロイ）
- **状態管理**: Riverpod 2.6.1
- **バックエンド**: Cloudflare Workers（TypeScript）
- **データベース**: Cloudflare D1（SQLite互換）
- **ホスティング**: Cloudflare Workers（静的アセット + API）
- **ルーティング**: go_router 14.6.2

## 機能

### ユーザー向け機能
- 検定一覧の表示
- 検定の問題に挑戦
- コラムの閲覧
- 問題の正誤判定と解説表示

### 管理者向け機能（Web）
- 検定の作成
- 問題の追加
- JSONインポート / エクスポート

## アーキテクチャ

```
Flutter Web (build/web)
       ↓
Cloudflare Worker (src/index.ts)
       ↓
  /api/* → D1 REST API
  その他 → Flutter Web アセット配信
```

## セットアップ手順

### 1. 依存パッケージのインストール

```bash
# Workerの依存パッケージ
npm install

# Flutterの依存パッケージ
cd bunrui_study && flutter pub get
```

### 2. D1データベースの作成

```bash
# D1データベース作成（初回のみ）
npx wrangler d1 create bunrui-study-db

# スキーマ適用（ローカル）
npm run db:migrate:local

# スキーマ適用（本番）
npm run db:migrate:remote
```

### 3. 環境変数の設定

`bunrui_study/.env` を作成：

```env
# ローカル開発
WORKER_API_URL=http://localhost:8787

# 本番デプロイ後
# WORKER_API_URL=https://bunrui-study.workers.dev
```

### 4. ローカル開発

```bash
# ① Flutter Webをビルド
cd bunrui_study && flutter build web

# ② Workerをローカル起動（別ターミナル）
cd .. && npx wrangler dev --local

# または Flutter を直接実行（APIはlocalhost:8787へ向ける）
cd bunrui_study && flutter run -d chrome
```

### 5. 本番デプロイ

```bash
# Flutter Web ビルド
cd bunrui_study && flutter build web

# Cloudflare Workers にデプロイ
cd .. && npx wrangler deploy
```

## REST API エンドポイント

| Method | Path | 説明 |
|--------|------|------|
| GET | `/api/kentei` | 検定一覧取得 |
| POST | `/api/kentei` | 検定作成 |
| PUT | `/api/kentei/:id` | 検定更新 |
| DELETE | `/api/kentei/:id` | 検定削除 |
| GET | `/api/kentei/:id/questions` | 問題一覧取得 |
| POST | `/api/kentei/:id/questions` | 問題作成 |
| PUT | `/api/questions/:id` | 問題更新 |
| DELETE | `/api/questions/:id` | 問題削除 |
| GET | `/api/kentei/:id/columns` | コラム一覧取得 |
| POST | `/api/kentei/:id/columns` | コラム作成 |
| DELETE | `/api/columns/:id` | コラム削除 |

## プロジェクト構造

```
bunrui-study/
├── src/
│   └── index.ts                # Cloudflare Worker (REST API)
├── d1_schema.sql               # D1データベーススキーマ
├── wrangler.jsonc              # Wrangler設定（D1バインディング含む）
├── package.json                # Node.js依存
├── tsconfig.json               # TypeScript設定
└── bunrui_study/               # Flutterアプリ
    ├── .env                    # 環境変数（WORKER_API_URL）
    ├── lib/
    │   ├── services/
    │   │   ├── supabase_service.dart   # ApiService（D1 REST APIクライアント）
    │   │   └── question_sync_service.dart
    │   ├── providers/
    │   │   └── supabase_provider.dart  # Riverpodプロバイダー
    │   ├── models/             # データモデル
    │   ├── screens/            # ユーザー向け画面
    │   └── admin/              # 管理者向け画面
    └── pubspec.yaml
```

## データベーススキーマ

### kentei（検定）
- id: TEXT（UUID）
- name: TEXT（検定名）
- description: TEXT（説明）
- created_at, updated_at: TEXT（ISO8601）

### questions（問題）
- id: TEXT（UUID）
- kentei_id: TEXT（外部キー）
- question_text: TEXT（問題文）
- question_type: TEXT（multiple_choice / text_input）
- option_a, option_b, option_c, option_d: TEXT
- correct_answer: TEXT（A/B/C/D またはひらがな）
- explanation: TEXT（解説）
- order_index: INTEGER
- created_at, updated_at: TEXT

### columns（コラム）
- id: TEXT（UUID）
- kentei_id: TEXT（外部キー）
- title: TEXT
- content: TEXT
- order_index: INTEGER
- created_at, updated_at: TEXT

## 今後の拡張予定

- [ ] コラム編集・削除機能
- [ ] 問題の編集機能
- [ ] ユーザーの学習履歴保存
- [ ] 問題のカテゴリ分類
- [ ] 画像添付機能
