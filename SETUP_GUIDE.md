# セットアップガイド

このガイドでは、検定学習アプリを最初から設定する手順を説明します。

## 前提条件

- Flutter SDKがインストールされていること
- Gitがインストールされていること
- Supabaseアカウント（無料で作成可能）

## ステップ1: Supabaseプロジェクトの作成

### 1.1 アカウント作成
1. https://supabase.com/ にアクセス
2. 「Start your project」をクリック
3. GitHubアカウントでサインイン（推奨）

### 1.2 新規プロジェクト作成
1. 「New Project」をクリック
2. プロジェクト名を入力（例: `kentei-app`）
3. データベースパスワードを設定（強力なパスワードを推奨）
4. リージョンを選択（日本なら`Northeast Asia (Tokyo)`が推奨）
5. 「Create new project」をクリック
6. プロジェクトの準備が完了するまで1-2分待つ

## ステップ2: データベースのセットアップ

### 2.1 SQLエディターを開く
1. Supabaseダッシュボードの左メニューから「SQL Editor」をクリック
2. 「New query」をクリック

### 2.2 スキーマを実行
1. このプロジェクトの`supabase_schema.sql`ファイルを開く
2. 内容を全てコピー
3. SQL Editorにペースト
4. 右下の「Run」ボタンをクリック
5. 成功メッセージが表示されることを確認

### 2.3 テーブル確認
1. 左メニューから「Table Editor」をクリック
2. 以下の3つのテーブルが作成されていることを確認：
   - `kentei`
   - `questions`
   - `columns`

## ステップ3: API認証情報の取得

1. 左メニューから「Settings」→「API」をクリック
2. 以下の情報をコピーして保存：
   - **Project URL**: `https://xxxxx.supabase.co`のような形式
   - **anon public key**: `eyJ...`で始まる長い文字列

**重要**: これらの情報は後で使用するので、安全な場所にメモしてください。

## ステップ4: Flutterアプリの設定

### 4.1 環境変数ファイルの作成
1. ターミナルで`kentei_app`ディレクトリに移動：
   ```bash
   cd kentei_app
   ```

2. `.env`ファイルを作成：
   ```bash
   cp .env.example .env
   ```

3. `.env`ファイルをエディタで開く：
   ```bash
   # macOS/Linux
   nano .env

   # またはお好みのエディタで
   code .env
   ```

4. 以下のように編集（ステップ3で取得した情報を使用）：
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

5. ファイルを保存

### 4.2 依存関係のインストール
```bash
flutter pub get
```

### 4.3 コード生成の実行
```bash
dart run build_runner build --delete-conflicting-outputs
```

## ステップ5: アプリの起動

### モバイル版（iOS/Android）
```bash
# 利用可能なデバイスを確認
flutter devices

# アプリを起動
flutter run
```

### Web版（管理画面用）
```bash
flutter run -d chrome
```

## ステップ6: 初期データの投入（オプション）

アプリが起動したら、管理画面から初期データを追加できます：

1. アプリ右上の管理アイコン（⚙️）をタップ
2. 右下の「+」ボタンをタップして検定を作成
3. 作成した検定の右側の「+」ボタンから問題を追加

## トラブルシューティング

### エラー: "Failed to load .env"
- `.env`ファイルが`kentei_app`ディレクトリに存在することを確認
- ファイル名が正確に`.env`であることを確認（`.env.txt`などではない）

### エラー: "Invalid Supabase credentials"
- `.env`ファイルの`SUPABASE_URL`と`SUPABASE_ANON_KEY`が正しいことを確認
- Supabaseダッシュボードで再度確認
- URLの末尾に余分なスラッシュがないことを確認

### エラー: "Table 'kentei' does not exist"
- ステップ2のデータベースセットアップが完了していることを確認
- Supabaseの「Table Editor」でテーブルが存在することを確認
- SQLを再実行してみる

### アプリが起動しない
```bash
# キャッシュをクリア
flutter clean

# 依存関係を再インストール
flutter pub get

# 再度起動
flutter run
```

## 次のステップ

セットアップが完了したら、[README.md](README.md)で使い方やプロジェクト構造を確認してください。

## サポート

問題が解決しない場合は、以下を確認してください：
- Flutter SDKのバージョン: `flutter --version`
- エラーログの詳細
- Supabaseのプロジェクトが正常に動作しているか
