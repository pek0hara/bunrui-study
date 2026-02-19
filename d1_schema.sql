-- D1 (SQLite) スキーマ
-- Supabase の UUID型・トリガーは使えないため、TEXT型IDとシンプルな構成に変更

-- 検定テーブル
CREATE TABLE IF NOT EXISTS kentei (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 問題テーブル
CREATE TABLE IF NOT EXISTS questions (
  id TEXT PRIMARY KEY,
  kentei_id TEXT NOT NULL REFERENCES kentei(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'text_input')),
  option_a TEXT,
  option_b TEXT,
  option_c TEXT,
  option_d TEXT,
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- コラムテーブル
CREATE TABLE IF NOT EXISTS columns (
  id TEXT PRIMARY KEY,
  kentei_id TEXT NOT NULL REFERENCES kentei(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  order_index INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_questions_kentei_id ON questions(kentei_id);
CREATE INDEX IF NOT EXISTS idx_columns_kentei_id ON columns(kentei_id);
