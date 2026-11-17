# Practice Exercise Hints

Nudges only — no full solutions. Try the exercises first, use these if you stall, then check [`ANSWERS.md`](./ANSWERS.md).

Each section mirrors the lesson path. Re-read the examples **above** the Practice Exercises in that file; the hints point at those patterns.

## 01 — Schema and alters

### `01-schema-and-alters/01-create-tables.sql`

1. Copy the shape of `posts` / `comments`: `uuid` PK with `gen_random_uuid()`, FKs to `profiles` and `posts`, `created_at timestamptz`.
2. A table-level `UNIQUE (…, …)` (or a composite unique constraint) stops the same person bookmarking the same post twice.

### `01-schema-and-alters/02-alter-tables.sql`

1. Prefer `ADD COLUMN IF NOT EXISTS` — same style as `posts.updated_at` earlier in this lesson.
2. Follow the lesson’s safe order: add nullable → `UPDATE … WHERE … IS NULL` → then set `DEFAULT` (and only then think about `NOT NULL`).

### `01-schema-and-alters/03-constraints-and-indexes.sql`

1. `CHECK (char_length(…))` on `profiles`, wrapped in a `DO $$ … EXCEPTION WHEN duplicate_object` block like the other constraints here.
2. Ask: what index does `UNIQUE (name)` on `tags` already create? A second plain index on the same column is usually redundant.

## 02 — Seed data

### `02-seed-data/01-seed-auth-and-profiles.sql`

1. Pick a new fixed uuid (same digit-style as alice/bob), then mirror the existing `auth.users` + `profiles` inserts for carol.
2. In `ON CONFLICT (id) DO UPDATE`, `EXCLUDED.column_name` is the row you tried to insert — include `username` in the `SET` list.

### `02-seed-data/02-seed-posts-comments-tags.sql`

1. New post id + Alice’s author id; set `published = true` and slug `rls-basics`, with the same `ON CONFLICT` style as the other posts.
2. Look up the seeded `supabase` tag id in this file; insert into `post_tags` with `ON CONFLICT (post_id, tag_id) DO NOTHING`.

## 03 — CRUD operations

### `03-crud-operations/01-select.sql`

1. Flip the published filter from the first query in this lesson (`WHERE published = …`).
2. `ORDER BY created_at DESC` plus `LIMIT` — same idea as “newest first,” but on `comments`.

### `03-crud-operations/02-insert-update-delete.sql`

1. Seed ids: Alice’s profile uuid and Bob’s draft post uuid are listed at the top of the seed lesson; use `RETURNING id`.
2. Scope the `UPDATE` with `WHERE slug = '…'` (Bob’s draft slug from seeds), and bump `updated_at` like the publish example.

### `03-crud-operations/03-crud-with-supabase-js.ts`

1. Chain `.from('profiles').select(…).eq('username', 'alice').single()` and always check `error`.
2. `.update({ body: … }).eq('id', 'c1111111-…').select(…)` — same `{ data, error }` habit as the other helpers in this file.

## 04 — Joins and views

### `04-joins-and-views/01-joins.sql`

1. Start from `comments`, `INNER JOIN` posts on `post_id`, then profiles on the **comment** `author_id` (not the post author).
2. `LEFT JOIN` profiles from posts, then `WHERE profiles.id IS NULL` to find orphans.

### `04-joins-and-views/02-views.sql`

1. Clone `published_posts_with_author`: `CREATE OR REPLACE VIEW … WITH (security_invoker = true) AS` and join `posts` → `post_tags` → `tags`.
2. `SELECT * FROM` the view and `ORDER BY` the slug and tag-name columns you aliased.

## 05 — Functions and triggers

### `05-functions-triggers/01-updated-at-trigger.sql`

1. Reuse `public.set_updated_at()` — only add the column on `profiles` and attach a `BEFORE UPDATE` trigger named like the posts/comments ones.
2. `UPDATE … WHERE username = 'alice' … RETURNING … updated_at` to prove the trigger fired.

### `05-functions-triggers/02-auth-users-sync.sql`

1. Same `->>'…'` pattern already used for `username` / `display_name`; add `bio` to the `INSERT` column list and values.
2. Think about race order: module 02 may insert the profile before Auth fires this trigger — what conflict clause keeps both paths safe?

### `05-functions-triggers/03-rpc-functions.sql`

1. Mirror `count_published_posts_for`: `LANGUAGE sql`, `STABLE`, `SECURITY INVOKER`, `SET search_path = ''`, `RETURNS TABLE (…)`.
2. After `CREATE FUNCTION`, `GRANT EXECUTE ON FUNCTION … TO authenticated` like the other rpcs in this lesson.

### `05-functions-triggers/04-rpc-with-supabase-js.ts`

1. `supabase.rpc('latest_posts', { limit_count: 5 })` — args object keys match the SQL parameter names.
2. Branch three ways: `error` present, success but empty array, success with rows (don’t treat “no rows” as an error).

## 06 — Row level security

### `06-row-level-security/01-enable-rls.sql`

1. Same one-liner as the other tables: `ALTER TABLE … ENABLE ROW LEVEL SECURITY` (only if `bookmarks` exists from module 01).
2. Catalog view: `pg_policies` filtered by `schemaname = 'public'` and `tablename = 'posts'`.

### `06-row-level-security/02-create-policies.sql`

1. `FOR DELETE` on `comments` with an `EXISTS (SELECT 1 FROM posts …)` so the **post** author matches `(SELECT auth.uid())`.
2. Write it once with bare `auth.uid()`, then wrap as `(SELECT auth.uid())` — the lesson intro explains the InitPlan / per-row cost difference.
