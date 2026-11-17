-- =============================================================================
-- Lesson: CREATE TABLE for the blog domain model
-- Why: Establish profiles, posts, comments, tags, and post_tags once so every
--      later module shares the same shape.
-- =============================================================================

-- Profiles mirror auth.users: one public row per signed-in user.
-- We use the same uuid as auth.users.id so joins and RLS stay simple.
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  username text NOT NULL,
  display_name text,
  bio text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Posts belong to a profile (the author).
CREATE TABLE IF NOT EXISTS public.posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  title text NOT NULL,
  body text NOT NULL DEFAULT '',
  published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Comments nest under a post and also record who wrote them.
CREATE TABLE IF NOT EXISTS public.comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.posts (id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Tags are shared labels; many posts can share one tag.
CREATE TABLE IF NOT EXISTS public.tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Junction table for the posts <-> tags many-to-many relationship.
CREATE TABLE IF NOT EXISTS public.post_tags (
  post_id uuid NOT NULL REFERENCES public.posts (id) ON DELETE CASCADE,
  tag_id uuid NOT NULL REFERENCES public.tags (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, tag_id)
);

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Add a table public.bookmarks with id, profile_id, post_id, and created_at.
-- 2. Ensure bookmarks uniquely pair one profile with one post.
-- -----------------------------------------------------------------------------
-- Hints: see HINTS.md · Solutions: see ANSWERS.md (same lesson path).
