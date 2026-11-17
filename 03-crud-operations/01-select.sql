-- =============================================================================
-- Lesson: SELECT — read posts, profiles, and comments
-- Why: Most app screens are filtered reads. Practice projection, WHERE, ORDER.
-- =============================================================================

-- All published posts, newest first
SELECT id, title, slug, author_id, created_at
FROM public.posts
WHERE published = true
ORDER BY created_at DESC;

-- One post by stable seed slug
SELECT id, title, body, published
FROM public.posts
WHERE slug = 'hello-supabase';

-- Authors only (useful for a directory page)
SELECT username, display_name, bio
FROM public.profiles
ORDER BY username;

-- Comments on Alice's demo post
SELECT id, author_id, body, created_at
FROM public.comments
WHERE post_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
ORDER BY created_at ASC;

-- Count posts per author (aggregate without a join lesson yet)
SELECT author_id, count(*) AS post_count
FROM public.posts
GROUP BY author_id;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Select titles of unpublished posts only.
-- 2. Select the two most recent comments (any post).
-- -----------------------------------------------------------------------------
-- Solutions: see ANSWERS.md (same lesson path).
