# 検定学習アプリ

FlutterとSupabaseで構築された検定学習アプリケーションです。

## 機能

### ユーザー向け機能
- 検定一覧の表示
- 検定の問題に挑戦
- コラムの閲覧
- 問題の正誤判定と解説表示

### 管理者向け機能（Web）
- 検定の作成
- 問題の追加
- コラムの追加（実装予定）

## セットアップ手順

### 1. Supabaseプロジェクトの作成

1. [Supabase](https://supabase.com/)にアクセスしてアカウントを作成
2. 新しいプロジェクトを作成

### 2. データベースのセットアップ

1. Supabaseのダッシュボードで「SQL Editor」を開く
2. `supabase_schema.sql`の内容をコピーして実行
3. テーブル（kentei, questions, columns）が作成されます

### 3. Supabaseの認証情報を取得

1. Supabaseのダッシュボードで「Settings」→「API」を開く
2. 以下の情報をコピー：
   - Project URL
   - anon public key

### 4. Flutterアプリの設定

1. `bunrui_study`ディレクトリに`.env`ファイルを作成
2. `.env.example`を参考に、以下の内容を記述：

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**重要**:
- `.env`ファイルは`.gitignore`に含まれているため、Gitにコミットされません
- セキュリティのため、認証情報は環境変数で管理します
- 本番環境では適切な環境変数管理を行ってください

### 5. アプリの起動

#### モバイル（iOS/Android）
```bash
cd bunrui_study
flutter run
```

#### Web（管理画面用）
```bash
cd bunrui_study
flutter run -d chrome
```

## プロジェクト構造

```
kentei-study/
├── supabase_schema.sql          # データベーススキーマ
├── README.md                    # このファイル
└── bunrui_study/                  # Flutterアプリ
    ├── .env.example             # 環境変数のサンプル
    ├── .env                     # 環境変数（要作成、Gitには含まれない）
    ├── lib/
    │   ├── models/              # データモデル
    │   │   ├── kentei.dart
    │   │   ├── question.dart
    │   │   └── column_model.dart
    │   ├── providers/           # Riverpodプロバイダー
    │   │   └── supabase_provider.dart
    │   ├── services/            # Supabaseサービス
    │   │   └── supabase_service.dart
    │   ├── screens/             # ユーザー向け画面
    │   │   ├── home_screen.dart
    │   │   ├── kentei_detail_screen.dart
    │   │   ├── question_screen.dart
    │   │   └── column_screen.dart
    │   ├── admin/               # 管理者向け画面
    │   │   ├── admin_home_screen.dart
    │   │   ├── kentei_create_screen.dart
    │   │   └── question_create_screen.dart
    │   └── main.dart
    └── pubspec.yaml
```

## 使い方

### モバイルアプリ
1. アプリを起動すると検定一覧が表示されます
2. 検定をタップして詳細画面へ
3. 「問題に挑戦」で問題を解く
4. 「コラムを読む」でコラムを閲覧

### 管理画面（Web）
1. ホーム画面右上の管理アイコンをタップ
2. 「+」ボタンで新しい検定を作成
3. 検定の右側の「+」ボタンで問題を追加

## 技術スタック

- **フロントエンド**: Flutter 3.9.2+
- **状態管理**: Riverpod 2.6.1
- **バックエンド**: Supabase
- **ルーティング**: go_router 14.6.2

## データベーススキーマ

### kentei（検定）
- id: UUID
- name: TEXT（検定名）
- description: TEXT（説明）
- created_at, updated_at: TIMESTAMP

### questions（問題）
- id: UUID
- kentei_id: UUID（外部キー）
- question_text: TEXT（問題文）
- option_a, option_b: TEXT（必須選択肢）
- option_c, option_d: TEXT（任意選択肢）
- correct_answer: TEXT（正解: A/B/C/D）
- explanation: TEXT（解説）
- order_index: INTEGER（表示順）
- created_at, updated_at: TIMESTAMP

### columns（コラム）
- id: UUID
- kentei_id: UUID（外部キー）
- title: TEXT（タイトル）
- content: TEXT（内容）
- order_index: INTEGER（表示順）
- created_at, updated_at: TIMESTAMP

## 今後の拡張予定

- [ ] コラム作成機能の追加
- [ ] 問題・コラムの編集・削除機能
- [ ] ユーザーの学習履歴保存
- [ ] 問題のカテゴリ分類
- [ ] 画像添付機能
