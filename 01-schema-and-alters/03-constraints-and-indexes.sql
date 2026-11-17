-- =============================================================================
-- Lesson: Constraints and indexes
-- Why: Constraints protect data integrity; indexes speed the lookups you do
--      often (by author, by slug, by tag name).
-- =============================================================================

-- UNIQUE / CHECK via DO blocks so re-running the lesson does not error.
-- Why: ADD CONSTRAINT has no IF NOT EXISTS on older Postgres; catch duplicates.

DO $$
BEGIN
  ALTER TABLE public.profiles
    ADD CONSTRAINT profiles_username_key UNIQUE (username);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.tags
    ADD CONSTRAINT tags_name_key UNIQUE (name);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- UNIQUE on posts.slug so URLs stay unambiguous.
DO $$
BEGIN
  ALTER TABLE public.posts
    ADD CONSTRAINT posts_slug_key UNIQUE (slug);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- CHECK: keep titles and bodies non-empty after trim.
DO $$
BEGIN
  ALTER TABLE public.posts
    ADD CONSTRAINT posts_title_not_blank
    CHECK (char_length(trim(title)) > 0);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.comments
    ADD CONSTRAINT comments_body_not_blank
    CHECK (char_length(trim(body)) > 0);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Indexes for common filters. Why btree (default): equality and range scans
-- on author_id / post_id dominate list pages.
CREATE INDEX IF NOT EXISTS posts_author_id_idx
  ON public.posts (author_id);

CREATE INDEX IF NOT EXISTS posts_published_created_at_idx
  ON public.posts (published, created_at DESC);

CREATE INDEX IF NOT EXISTS comments_post_id_idx
  ON public.comments (post_id);

CREATE INDEX IF NOT EXISTS comments_author_id_idx
  ON public.comments (author_id);

CREATE INDEX IF NOT EXISTS post_tags_tag_id_idx
  ON public.post_tags (tag_id);

-- WARNING: Extra indexes slow writes and use disk. Index columns you filter or
-- join on — not every column "just in case".

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Add a CHECK that profiles.username is at least 3 characters.
-- 2. Create an index on tags(name) — or explain why UNIQUE already covers it.
-- -----------------------------------------------------------------------------
-- Solutions: see ANSWERS.md (same lesson path).
