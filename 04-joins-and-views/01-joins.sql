-- =============================================================================
-- Lesson: INNER JOIN and LEFT JOIN
-- Why: Posts alone are not enough — UIs need author names, comment counts, tags.
-- =============================================================================

-- INNER JOIN: only posts that have a matching profile (authors).
-- Rows without a match are dropped — fine when author_id is NOT NULL + FK.
SELECT
  p.title,
  p.slug,
  pr.username AS author_username,
  p.published,
  p.created_at
FROM public.posts AS p
INNER JOIN public.profiles AS pr
  ON pr.id = p.author_id
ORDER BY p.created_at DESC;

-- Comments with author username (INNER: skip orphaned comments if any)
SELECT
  c.body AS comment_body,
  pr.username AS commenter,
  p.title AS post_title
FROM public.comments AS c
INNER JOIN public.profiles AS pr ON pr.id = c.author_id
INNER JOIN public.posts AS p ON p.id = c.post_id
ORDER BY c.created_at;

-- LEFT JOIN: keep every post even if it has zero comments.
-- Why LEFT: feed pages still show posts with an empty comment list.
SELECT
  p.title,
  c.body AS comment_body,
  c.created_at AS commented_at
FROM public.posts AS p
LEFT JOIN public.comments AS c
  ON c.post_id = p.id
ORDER BY p.title, c.created_at;

-- Posts with tag names via the junction table
SELECT
  p.title,
  t.name AS tag_name
FROM public.posts AS p
INNER JOIN public.post_tags AS pt ON pt.post_id = p.id
INNER JOIN public.tags AS t ON t.id = pt.tag_id
ORDER BY p.title, t.name;

-- LEFT JOIN tags: include posts that have no tags yet
SELECT
  p.title,
  t.name AS tag_name
FROM public.posts AS p
LEFT JOIN public.post_tags AS pt ON pt.post_id = p.id
LEFT JOIN public.tags AS t ON t.id = pt.tag_id
ORDER BY p.title;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. List each comment with the post slug and the commenter's display_name.
-- 2. LEFT JOIN profiles to posts so you could spot posts with a missing author
--    (should be empty if FKs are healthy).
-- 3. List posts that have no tags (LEFT JOIN post_tags, filter where the join is NULL).
-- -----------------------------------------------------------------------------
-- Hints: see HINTS.md · Solutions: see ANSWERS.md (same lesson path).
