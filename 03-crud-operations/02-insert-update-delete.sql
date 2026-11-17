-- =============================================================================
-- Lesson: INSERT / UPDATE / DELETE
-- Why: Mutations need precise WHERE clauses. Always prefer RETURNING so you
--      can see what changed.
-- =============================================================================

-- INSERT a new draft for Alice (new random id via default)
INSERT INTO public.posts (author_id, title, slug, body, published)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'Working with CRUD',
  'working-with-crud',
  'Notes from the CRUD lesson.',
  false
)
RETURNING id, slug, published;

-- UPDATE: publish that draft by slug
-- WARNING: UPDATE without WHERE updates every row — always scope the WHERE.
UPDATE public.posts
SET
  published = true,
  updated_at = now()
WHERE slug = 'working-with-crud'
RETURNING id, slug, published, updated_at;

-- UPDATE a comment body
UPDATE public.comments
SET body = 'Great intro — thanks Alice! (edited)'
WHERE id = 'c1111111-1111-1111-1111-111111111111'
RETURNING id, body;

-- DELETE a row you are willing to lose
-- WARNING: DELETE is permanent. Prefer soft-delete columns in production apps.
-- This example deletes the draft we just published if you want a clean slate.
-- Uncomment to run:
-- DELETE FROM public.posts
-- WHERE slug = 'working-with-crud'
-- RETURNING id, slug;

-- Safer delete pattern: delete only if unpublished
DELETE FROM public.posts
WHERE slug = 'working-with-crud'
  AND published = false
RETURNING id, slug;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Insert a comment from Alice on Bob's draft post; RETURNING id.
-- 2. Update Bob's draft title to 'Draft: Better Indexes' by slug.
-- -----------------------------------------------------------------------------
-- Hints: see HINTS.md · Solutions: see ANSWERS.md (same lesson path).
