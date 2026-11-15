-- =============================================================================
-- Lesson: ENABLE ROW LEVEL SECURITY
-- Why: Supabase exposes tables through PostgREST. Without RLS, any client with the
--      anon key can read/write everything the GRANTs allow.
-- =============================================================================

-- Enable RLS on every public domain table.
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_tags ENABLE ROW LEVEL SECURITY;

-- Optional but recommended: force RLS even for table owners in the Dashboard
-- SQL role discussions — usually leave OFF so migrations still work as postgres.
-- ALTER TABLE public.posts FORCE ROW LEVEL SECURITY;

-- WARNING: After ENABLE and before CREATE POLICY, authenticated/anon clients
-- see zero rows. Continue immediately with 02-create-policies.sql.

-- Inspect RLS flags
SELECT
  c.relname AS table_name,
  c.relrowsecurity AS rls_enabled,
  c.relforcerowsecurity AS rls_forced
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('profiles', 'posts', 'comments', 'tags', 'post_tags')
ORDER BY c.relname;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Enable RLS on public.bookmarks if you created that practice table in 01.
-- 2. Query pg_policies for public.posts (expect few/none until lesson 02).
-- -----------------------------------------------------------------------------

/*
-- Solutions

ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

SELECT * FROM pg_policies WHERE schemaname = 'public' AND tablename = 'posts';

*/
