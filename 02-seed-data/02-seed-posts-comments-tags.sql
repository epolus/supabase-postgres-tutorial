-- =============================================================================
-- Lesson: Seed posts, comments, tags, and post_tags idempotently
-- Why: Downstream CRUD / join lessons need predictable rows. Fixed uuids +
--      ON CONFLICT make the script re-runnable.
-- =============================================================================

-- Demo post ids
-- alice's post: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
-- bob's post:   bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb

INSERT INTO public.posts (id, author_id, title, slug, body, published, created_at)
VALUES
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'Hello Supabase',
    'hello-supabase',
    'A first post about Postgres on Supabase.',
    true,
    now()
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '22222222-2222-2222-2222-222222222222',
    'Draft: Index Thoughts',
    'draft-index-thoughts',
    'Still writing — not published yet.',
    false,
    now()
  )
ON CONFLICT (id) DO UPDATE
SET
  title = EXCLUDED.title,
  slug = EXCLUDED.slug,
  body = EXCLUDED.body,
  published = EXCLUDED.published;

-- Tags
INSERT INTO public.tags (id, name)
VALUES
  ('d1111111-1111-1111-1111-111111111111', 'postgres'),
  ('d2222222-2222-2222-2222-222222222222', 'supabase'),
  ('d3333333-3333-3333-3333-333333333333', 'tutorial')
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name;

-- Attach tags to Alice's published post
INSERT INTO public.post_tags (post_id, tag_id)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'd1111111-1111-1111-1111-111111111111'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'd2222222-2222-2222-2222-222222222222'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'd3333333-3333-3333-3333-333333333333')
ON CONFLICT (post_id, tag_id) DO NOTHING;

-- Comments: Bob comments on Alice's post; Alice replies on her own post
INSERT INTO public.comments (id, post_id, author_id, body)
VALUES
  (
    'c1111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '22222222-2222-2222-2222-222222222222',
    'Great intro — thanks Alice!'
  ),
  (
    'c2222222-2222-2222-2222-222222222222',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'Glad it helped, Bob.'
  )
ON CONFLICT (id) DO UPDATE
SET body = EXCLUDED.body;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Seed a third published post by Alice with slug 'rls-basics'.
-- 2. Tag that post with 'supabase' only, using ON CONFLICT DO NOTHING.
-- -----------------------------------------------------------------------------

/*
-- Solutions

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

*/
