-- =============================================================================
-- Lesson: PL/pgSQL functions exposed as rpc
-- Why: Encapsulate multi-step or privileged logic and call it with supabase.rpc.
-- =============================================================================

-- Count published posts for a given author username.
-- INVOKER is enough here: we only read tables the caller can already see.
CREATE OR REPLACE FUNCTION public.count_published_posts_for(username text)
RETURNS bigint
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT count(*)::bigint
  FROM public.posts AS p
  INNER JOIN public.profiles AS pr ON pr.id = p.author_id
  WHERE pr.username = count_published_posts_for.username
    AND p.published = true;
$$;

-- Publish all of the caller's draft posts.
-- Uses (select auth.uid()) pattern so it stays RLS-friendly when policies exist.
CREATE OR REPLACE FUNCTION public.publish_my_drafts()
RETURNS setof public.posts
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  UPDATE public.posts AS p
  SET
    published = true,
    updated_at = now()
  WHERE p.author_id = (SELECT auth.uid())
    AND p.published = false
  RETURNING p.*;
END;
$$;

-- Demo (runs as the SQL Editor role — auth.uid() may be null there).
SELECT public.count_published_posts_for('alice') AS alice_published_count;

-- Grant execute to authenticated clients (typical for rpc from the browser)
GRANT EXECUTE ON FUNCTION public.count_published_posts_for(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.publish_my_drafts() TO authenticated;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Write public.latest_posts(limit_count int) returning id, title, slug.
-- 2. GRANT EXECUTE on it to authenticated.
-- -----------------------------------------------------------------------------

/*
-- Solutions

CREATE OR REPLACE FUNCTION public.latest_posts(limit_count int DEFAULT 10)
RETURNS TABLE (id uuid, title text, slug text)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT p.id, p.title, p.slug
  FROM public.posts AS p
  WHERE p.published = true
  ORDER BY p.created_at DESC
  LIMIT greatest(limit_count, 0);
$$;

GRANT EXECUTE ON FUNCTION public.latest_posts(int) TO authenticated;

*/
