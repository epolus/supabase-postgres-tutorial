-- =============================================================================
-- Lesson: ALTER TABLE — evolve the schema without reckless drops
-- Why: Real apps change. Prefer additive, idempotent alters and warn before
--      anything that can lose or rewrite existing rows.
-- =============================================================================

-- SAFE: add a column only if it is missing (Postgres 9.1+ supports IF NOT EXISTS
-- on ADD COLUMN in modern Supabase / Postgres versions).
ALTER TABLE public.posts
  ADD COLUMN IF NOT EXISTS slug text;

ALTER TABLE public.posts
  ADD COLUMN IF NOT EXISTS updated_at timestamptz;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS avatar_url text;

-- SAFE pattern for backfilling a new NOT NULL column:
-- 1) add nullable, 2) UPDATE existing rows, 3) set NOT NULL.
-- WARNING: step 3 fails (and blocks writes) if any row still has NULL.
UPDATE public.posts
SET slug = lower(regexp_replace(title, '[^a-zA-Z0-9]+', '-', 'g'))
WHERE slug IS NULL;

-- Only enforce NOT NULL after data is filled.
ALTER TABLE public.posts
  ALTER COLUMN slug SET NOT NULL;

-- Give updated_at a default going forward (existing NULLs stay until a trigger
-- or UPDATE touches them — see module 05).
ALTER TABLE public.posts
  ALTER COLUMN updated_at SET DEFAULT now();

-- WARNING (data impact): DROP COLUMN permanently deletes that column's data.
-- Prefer IF EXISTS and only run after you are sure nothing depends on it.
-- Example (commented out on purpose):
-- ALTER TABLE public.profiles DROP COLUMN IF EXISTS bio;

-- WARNING (data impact): RENAME can break application code and views that still
-- use the old name. Coordinate deploys before renaming in production.
-- Example (commented out):
-- ALTER TABLE public.posts RENAME COLUMN body TO content;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Add comments.updated_at timestamptz with DEFAULT now() if missing.
-- 2. Backfill NULL updated_at on comments to now() safely.
-- -----------------------------------------------------------------------------
-- Hints: see HINTS.md · Solutions: see ANSWERS.md (same lesson path).
