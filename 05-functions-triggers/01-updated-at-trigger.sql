-- =============================================================================
-- Lesson: updated_at trigger
-- Why: Application code forgets timestamps. A BEFORE UPDATE trigger keeps
--      updated_at honest on every change.
-- =============================================================================

-- Ensure the column exists (from module 01 alters; safe if already present)
ALTER TABLE public.posts
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

ALTER TABLE public.comments
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- SECURITY DEFINER + empty search_path: avoid search_path injection.
-- Fully qualify everything inside (public.set_updated_at uses NEW only here).
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Why: force the timestamp at write time so clients cannot forge "fresh" rows.
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- Drop + create keeps re-runs idempotent for this lesson
DROP TRIGGER IF EXISTS posts_set_updated_at ON public.posts;
CREATE TRIGGER posts_set_updated_at
  BEFORE UPDATE ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS comments_set_updated_at ON public.comments;
CREATE TRIGGER comments_set_updated_at
  BEFORE UPDATE ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- Demo: update a post and observe updated_at change
UPDATE public.posts
SET body = body || E'\n\n(updated_at trigger demo)'
WHERE slug = 'hello-supabase'
RETURNING id, slug, updated_at;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Add updated_at to public.profiles if missing and attach the same trigger.
-- 2. UPDATE alice's bio and RETURNING updated_at.
-- -----------------------------------------------------------------------------
-- Solutions: see ANSWERS.md (same lesson path).
