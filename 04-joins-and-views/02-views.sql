-- =============================================================================
-- Lesson: Views with security_invoker = true
-- Why: Views package joins for reuse. On Supabase, always use security_invoker
--      so the caller's RLS policies apply to the underlying tables.
-- =============================================================================

-- Published posts with author username — a common feed shape.
-- security_invoker = true: run as the selecting role, not the view owner.
CREATE OR REPLACE VIEW public.published_posts_with_author
WITH (security_invoker = true)
AS
SELECT
  p.id,
  p.title,
  p.slug,
  p.body,
  p.created_at,
  pr.username AS author_username,
  pr.display_name AS author_display_name
FROM public.posts AS p
INNER JOIN public.profiles AS pr
  ON pr.id = p.author_id
WHERE p.published = true;

-- Post comment counts (posts with zero comments still appear via LEFT JOIN)
CREATE OR REPLACE VIEW public.post_comment_counts
WITH (security_invoker = true)
AS
SELECT
  p.id AS post_id,
  p.title,
  p.slug,
  count(c.id) AS comment_count
FROM public.posts AS p
LEFT JOIN public.comments AS c
  ON c.post_id = p.id
GROUP BY p.id, p.title, p.slug;

-- Read through the views like tables
SELECT * FROM public.published_posts_with_author
ORDER BY created_at DESC;

SELECT * FROM public.post_comment_counts
ORDER BY comment_count DESC, title;

-- WARNING: Views without security_invoker default to the view owner's rights
-- (security_definer behavior). That can accidentally bypass RLS — avoid it.

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Create view public.post_tags_list (security_invoker) with post slug + tag name.
-- 2. SELECT from it ordered by slug, name.
-- 3. Create view public.tag_post_counts (security_invoker) with tag name + COUNT of posts.
-- -----------------------------------------------------------------------------
-- Hints: see HINTS.md · Solutions: see ANSWERS.md (same lesson path).
