# Practice Exercise Answers

Spoiler file: solutions extracted from the lesson files so you can try the **Practice Exercises** first.
Prefer [`HINTS.md`](./HINTS.md) before opening a solution.

Each section mirrors the lesson path under the module folders.

## 01 — Schema and alters

### `01-schema-and-alters/01-create-tables.sql`

Practice Exercises
1. Add a table public.bookmarks with id, profile_id, post_id, and created_at.
2. Ensure bookmarks uniquely pair one profile with one post.

```sql
CREATE TABLE IF NOT EXISTS public.bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  post_id uuid NOT NULL REFERENCES public.posts (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (profile_id, post_id)
);
```

### `01-schema-and-alters/02-alter-tables.sql`

Practice Exercises
1. Add comments.updated_at timestamptz with DEFAULT now() if missing.
2. Backfill NULL updated_at on comments to now() safely.

```sql
ALTER TABLE public.comments
  ADD COLUMN IF NOT EXISTS updated_at timestamptz;

UPDATE public.comments
SET updated_at = now()
WHERE updated_at IS NULL;

ALTER TABLE public.comments
  ALTER COLUMN updated_at SET DEFAULT now();
```

### `01-schema-and-alters/03-constraints-and-indexes.sql`

Practice Exercises
1. Add a CHECK that profiles.username is at least 3 characters.
2. Create an index on tags(name) — or explain why UNIQUE already covers it.

```sql
ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_username_min_length
  CHECK (char_length(username) >= 3);

-- A UNIQUE constraint already creates a unique index on tags(name), so a
-- separate CREATE INDEX on name alone is usually redundant:
-- CREATE UNIQUE INDEX ... is what UNIQUE builds under the hood.
```

## 02 — Seed data

### `02-seed-data/01-seed-auth-and-profiles.sql`

Practice Exercises
1. Seed a third user + profile (carol) with a new fixed uuid.
2. Make the profile upsert also refresh username from EXCLUDED.

```sql
INSERT INTO auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
) VALUES (
  '33333333-3333-3333-3333-333333333333',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'carol@example.com',
  crypt('password123', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"username":"carol"}'::jsonb, now(), now(),
  '', '', '', ''
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, username, display_name, bio)
VALUES (
  '33333333-3333-3333-3333-333333333333',
  'carol', 'Carol Clark', 'Trigger enthusiast.'
)
ON CONFLICT (id) DO UPDATE
SET
  username = EXCLUDED.username,
  display_name = EXCLUDED.display_name,
  bio = EXCLUDED.bio;
```

### `02-seed-data/02-seed-posts-comments-tags.sql`

Practice Exercises
1. Seed a third published post by Alice with slug 'rls-basics'.
2. Tag that post with 'supabase' only, using ON CONFLICT DO NOTHING.

```sql
INSERT INTO public.posts (id, author_id, title, slug, body, published)
VALUES (
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  '11111111-1111-1111-1111-111111111111',
  'RLS Basics',
  'rls-basics',
  'We will lock down rows later.',
  true
)
ON CONFLICT (id) DO UPDATE
SET title = EXCLUDED.title, slug = EXCLUDED.slug, body = EXCLUDED.body, published = EXCLUDED.published;

INSERT INTO public.post_tags (post_id, tag_id)
VALUES (
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  'd2222222-2222-2222-2222-222222222222'
)
ON CONFLICT (post_id, tag_id) DO NOTHING;
```

## 03 — CRUD operations

### `03-crud-operations/01-select.sql`

Practice Exercises
1. Select titles of unpublished posts only.
2. Select the two most recent comments (any post).

```sql
SELECT id, title, slug
FROM public.posts
WHERE published = false;

SELECT id, post_id, body, created_at
FROM public.comments
ORDER BY created_at DESC
LIMIT 2;
```

### `03-crud-operations/02-insert-update-delete.sql`

Practice Exercises
1. Insert a comment from Alice on Bob's draft post; RETURNING id.
2. Update Bob's draft title to 'Draft: Better Indexes' by slug.

```sql
INSERT INTO public.comments (post_id, author_id, body)
VALUES (
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '11111111-1111-1111-1111-111111111111',
  'Looking forward to the published version.'
)
RETURNING id;

UPDATE public.posts
SET title = 'Draft: Better Indexes', updated_at = now()
WHERE slug = 'draft-index-thoughts'
RETURNING id, title;
```

### `03-crud-operations/03-crud-with-supabase-js.ts`

Practice Exercises
1. Fetch profile username + display_name for alice.
2. Update comment c1111111-... body via .update().eq('id', ...).

```ts
const { data, error } = await supabase
  .from('profiles')
  .select('username, display_name')
  .eq('username', 'alice')
  .single()
if (error) console.error(error.message)
else console.log(data)

const { data: updated, error: updateError } = await supabase
  .from('comments')
  .update({ body: 'Edited from the SDK' })
  .eq('id', 'c1111111-1111-1111-1111-111111111111')
  .select('id, body')
if (updateError) console.error(updateError.message)
else console.log(updated)
```

## 04 — Joins and views

### `04-joins-and-views/01-joins.sql`

Practice Exercises
1. List each comment with the post slug and the commenter's display_name.
2. LEFT JOIN profiles to posts so you could spot posts with a missing author
   (should be empty if FKs are healthy).

```sql
SELECT
  c.body,
  p.slug AS post_slug,
  pr.display_name AS commenter_name
FROM public.comments AS c
INNER JOIN public.posts AS p ON p.id = c.post_id
INNER JOIN public.profiles AS pr ON pr.id = c.author_id;

SELECT
  p.id,
  p.title,
  pr.username
FROM public.posts AS p
LEFT JOIN public.profiles AS pr ON pr.id = p.author_id
WHERE pr.id IS NULL;
```

### `04-joins-and-views/02-views.sql`

Practice Exercises
1. Create view public.post_tags_list (security_invoker) with post slug + tag name.
2. SELECT from it ordered by slug, name.

```sql
CREATE OR REPLACE VIEW public.post_tags_list
WITH (security_invoker = true)
AS
SELECT
  p.slug AS post_slug,
  t.name AS tag_name
FROM public.posts AS p
INNER JOIN public.post_tags AS pt ON pt.post_id = p.id
INNER JOIN public.tags AS t ON t.id = pt.tag_id;

SELECT * FROM public.post_tags_list
ORDER BY post_slug, tag_name;
```

## 05 — Functions and triggers

### `05-functions-triggers/01-updated-at-trigger.sql`

Practice Exercises
1. Add updated_at to public.profiles if missing and attach the same trigger.
2. UPDATE alice's bio and RETURNING updated_at.

```sql
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

DROP TRIGGER IF EXISTS profiles_set_updated_at ON public.profiles;
CREATE TRIGGER profiles_set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

UPDATE public.profiles
SET bio = 'Writes about databases, tea, and triggers.'
WHERE username = 'alice'
RETURNING id, username, updated_at;
```

### `05-functions-triggers/02-auth-users-sync.sql`

Practice Exercises
1. Extend handle_new_user to copy bio from raw_user_meta_data->>'bio' when set.
2. Explain why ON CONFLICT DO NOTHING is useful if you also seed profiles.

```sql
-- In the INSERT column list add bio, and in VALUES:
--   NEW.raw_user_meta_data ->> 'bio'
--
-- ON CONFLICT DO NOTHING: seed scripts (module 02) may insert the profile
-- before or after Auth. Ignoring conflicts keeps signup and seeds compatible.
```

### `05-functions-triggers/03-rpc-functions.sql`

Practice Exercises
1. Write public.latest_posts(limit_count int) returning id, title, slug.
2. GRANT EXECUTE on it to authenticated.

```sql
CREATE OR REPLACE FUNCTION public.latest_posts(limit_count int DEFAULT 10)
RETURNS TABLE (id uuid, title text, slug text)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT p.id, p.title, p.slug
  FROM public.posts AS p
  WHERE p.published = true
  ORDER BY p.created_at DESC
  LIMIT greatest(limit_count, 0);
$$;

GRANT EXECUTE ON FUNCTION public.latest_posts(int) TO authenticated;
```

### `05-functions-triggers/04-rpc-with-supabase-js.ts`

Practice Exercises
1. Call latest_posts with limit_count: 5 (after creating it in 03).
2. Log a clear message when error is non-null vs when data is empty.

```ts
const { data, error } = await supabase.rpc('latest_posts', { limit_count: 5 })
if (error) {
  console.error('latest_posts failed:', error.message)
} else if (!data?.length) {
  console.log('No published posts yet')
} else {
  console.log(data)
}
```

## 06 — Row level security

### `06-row-level-security/01-enable-rls.sql`

Practice Exercises
1. Enable RLS on public.bookmarks if you created that practice table in 01.
2. Query pg_policies for public.posts (expect few/none until lesson 02).

```sql
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

SELECT * FROM pg_policies WHERE schemaname = 'public' AND tablename = 'posts';
```

### `06-row-level-security/02-create-policies.sql`

Practice Exercises
1. Add a policy allowing post authors to DELETE comments on their own posts.
2. Rewrite one policy using bare auth.uid(), then change it to
   (select auth.uid()) and note why the select form is preferred.

```sql
DROP POLICY IF EXISTS "comments_delete_post_author" ON public.comments;
CREATE POLICY "comments_delete_post_author"
  ON public.comments
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.posts AS p
      WHERE p.id = comments.post_id
        AND p.author_id = (SELECT auth.uid())
    )
  );

-- Prefer (SELECT auth.uid()) so the uid is evaluated once per statement
-- (InitPlan) instead of per-row as a volatile function call.
```

