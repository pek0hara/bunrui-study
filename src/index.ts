export interface Env {
  DB: D1Database;
  ASSETS: Fetcher;
}

// シンプルなUUID生成（crypto.randomUUID()使用）
function generateId(): string {
  return crypto.randomUUID();
}

// CORSヘッダー（Flutter Web/デバッグ用）
function corsHeaders(): HeadersInit {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json',
  };
}

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: corsHeaders(),
  });
}

function errorResponse(message: string, status = 400): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: corsHeaders(),
  });
}

// ルーティング
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    // CORS preflight
    if (method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    // API ルート
    if (path.startsWith('/api/')) {
      return handleApi(request, env, url, path, method);
    }

    // それ以外はFlutter Webアセットを返す
    return env.ASSETS.fetch(request);
  },
};

async function handleApi(
  request: Request,
  env: Env,
  url: URL,
  path: string,
  method: string
): Promise<Response> {
  try {
    // GET /api/kentei - 検定一覧取得
    if (path === '/api/kentei' && method === 'GET') {
      const { results } = await env.DB.prepare(
        'SELECT * FROM kentei ORDER BY created_at ASC'
      ).all();
      return jsonResponse(results);
    }

    // POST /api/kentei - 検定作成
    if (path === '/api/kentei' && method === 'POST') {
      const body = await request.json<{ name: string; description?: string }>();
      if (!body.name) return errorResponse('name is required');
      const id = generateId();
      const now = new Date().toISOString();
      await env.DB.prepare(
        'INSERT INTO kentei (id, name, description, created_at, updated_at) VALUES (?, ?, ?, ?, ?)'
      )
        .bind(id, body.name, body.description ?? null, now, now)
        .run();
      const kentei = await env.DB.prepare('SELECT * FROM kentei WHERE id = ?')
        .bind(id)
        .first();
      return jsonResponse(kentei, 201);
    }

    // PUT /api/kentei/:id - 検定更新
    const kenteiUpdateMatch = path.match(/^\/api\/kentei\/([^/]+)$/);
    if (kenteiUpdateMatch && method === 'PUT') {
      const id = kenteiUpdateMatch[1];
      const body = await request.json<{ name?: string; description?: string }>();
      const now = new Date().toISOString();
      const fields: string[] = ['updated_at = ?'];
      const values: unknown[] = [now];
      if (body.name !== undefined) { fields.push('name = ?'); values.push(body.name); }
      if (body.description !== undefined) { fields.push('description = ?'); values.push(body.description); }
      values.push(id);
      await env.DB.prepare(
        `UPDATE kentei SET ${fields.join(', ')} WHERE id = ?`
      )
        .bind(...values)
        .run();
      const kentei = await env.DB.prepare('SELECT * FROM kentei WHERE id = ?')
        .bind(id)
        .first();
      if (!kentei) return errorResponse('Not found', 404);
      return jsonResponse(kentei);
    }

    // DELETE /api/kentei/:id - 検定削除
    if (kenteiUpdateMatch && method === 'DELETE') {
      const id = kenteiUpdateMatch[1];
      await env.DB.prepare('DELETE FROM kentei WHERE id = ?').bind(id).run();
      return jsonResponse({ success: true });
    }

    // GET /api/kentei/:id/questions - 問題一覧取得
    const questionsMatch = path.match(/^\/api\/kentei\/([^/]+)\/questions$/);
    if (questionsMatch && method === 'GET') {
      const kenteiId = questionsMatch[1];
      const { results } = await env.DB.prepare(
        'SELECT * FROM questions WHERE kentei_id = ? ORDER BY order_index ASC'
      )
        .bind(kenteiId)
        .all();
      return jsonResponse(results);
    }

    // POST /api/kentei/:id/questions - 問題作成
    if (questionsMatch && method === 'POST') {
      const kenteiId = questionsMatch[1];
      const body = await request.json<{
        question_text: string;
        question_type?: string;
        option_a?: string;
        option_b?: string;
        option_c?: string;
        option_d?: string;
        correct_answer: string;
        explanation?: string;
        order_index?: number;
      }>();
      if (!body.question_text) return errorResponse('question_text is required');
      if (!body.correct_answer) return errorResponse('correct_answer is required');
      const id = generateId();
      const now = new Date().toISOString();
      await env.DB.prepare(
        `INSERT INTO questions
          (id, kentei_id, question_text, question_type, option_a, option_b, option_c, option_d,
           correct_answer, explanation, order_index, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
      )
        .bind(
          id,
          kenteiId,
          body.question_text,
          body.question_type ?? 'multiple_choice',
          body.option_a ?? null,
          body.option_b ?? null,
          body.option_c ?? null,
          body.option_d ?? null,
          body.correct_answer,
          body.explanation ?? null,
          body.order_index ?? 0,
          now,
          now
        )
        .run();
      const question = await env.DB.prepare(
        'SELECT * FROM questions WHERE id = ?'
      )
        .bind(id)
        .first();
      return jsonResponse(question, 201);
    }

    // PUT /api/questions/:id - 問題更新
    const questionUpdateMatch = path.match(/^\/api\/questions\/([^/]+)$/);
    if (questionUpdateMatch && method === 'PUT') {
      const id = questionUpdateMatch[1];
      const body = await request.json<Record<string, unknown>>();
      const now = new Date().toISOString();
      const fields: string[] = ['updated_at = ?'];
      const values: unknown[] = [now];
      const allowed = [
        'question_text', 'question_type', 'option_a', 'option_b',
        'option_c', 'option_d', 'correct_answer', 'explanation', 'order_index'
      ];
      for (const key of allowed) {
        if (body[key] !== undefined) {
          fields.push(`${key} = ?`);
          values.push(body[key]);
        }
      }
      values.push(id);
      await env.DB.prepare(
        `UPDATE questions SET ${fields.join(', ')} WHERE id = ?`
      )
        .bind(...values)
        .run();
      const question = await env.DB.prepare(
        'SELECT * FROM questions WHERE id = ?'
      )
        .bind(id)
        .first();
      if (!question) return errorResponse('Not found', 404);
      return jsonResponse(question);
    }

    // DELETE /api/questions/:id - 問題削除
    if (questionUpdateMatch && method === 'DELETE') {
      const id = questionUpdateMatch[1];
      await env.DB.prepare('DELETE FROM questions WHERE id = ?').bind(id).run();
      return jsonResponse({ success: true });
    }

    // GET /api/kentei/:id/columns - コラム一覧取得
    const columnsMatch = path.match(/^\/api\/kentei\/([^/]+)\/columns$/);
    if (columnsMatch && method === 'GET') {
      const kenteiId = columnsMatch[1];
      const { results } = await env.DB.prepare(
        'SELECT * FROM columns WHERE kentei_id = ? ORDER BY order_index ASC'
      )
        .bind(kenteiId)
        .all();
      return jsonResponse(results);
    }

    // POST /api/kentei/:id/columns - コラム作成
    if (columnsMatch && method === 'POST') {
      const kenteiId = columnsMatch[1];
      const body = await request.json<{
        title: string;
        content: string;
        order_index?: number;
      }>();
      if (!body.title) return errorResponse('title is required');
      if (!body.content) return errorResponse('content is required');
      const id = generateId();
      const now = new Date().toISOString();
      await env.DB.prepare(
        `INSERT INTO columns (id, kentei_id, title, content, order_index, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`
      )
        .bind(id, kenteiId, body.title, body.content, body.order_index ?? 0, now, now)
        .run();
      const column = await env.DB.prepare(
        'SELECT * FROM columns WHERE id = ?'
      )
        .bind(id)
        .first();
      return jsonResponse(column, 201);
    }

    // DELETE /api/columns/:id - コラム削除
    const columnDeleteMatch = path.match(/^\/api\/columns\/([^/]+)$/);
    if (columnDeleteMatch && method === 'DELETE') {
      const id = columnDeleteMatch[1];
      await env.DB.prepare('DELETE FROM columns WHERE id = ?').bind(id).run();
      return jsonResponse({ success: true });
    }

    return errorResponse('Not found', 404);
  } catch (e) {
    console.error(e);
    return errorResponse(`Internal server error: ${(e as Error).message}`, 500);
  }
}
