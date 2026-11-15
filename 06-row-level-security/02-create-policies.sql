-- =============================================================================
-- Lesson: CREATE POLICY for the blog domain
-- Why: Encode who can read and write each table. Use (select auth.uid()) so
--      Postgres can treat the uid as a stable InitPlan value per statement.
-- =============================================================================

-- ---------- profiles ----------
-- Anyone can read profiles (public author pages).
DROP POLICY IF EXISTS "profiles_select_all" ON public.profiles;
CREATE POLICY "profiles_select_all"
  ON public.profiles
  FOR SELECT
  TO authenticated, anon
  USING (true);

-- Users update only their own profile row.
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (id = (SELECT auth.uid()))
  WITH CHECK (id = (SELECT auth.uid()));

-- Inserts normally come from the auth trigger (SECURITY DEFINER). Allow
-- authenticated insert of own row for completeness / manual repairs.
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
CREATE POLICY "profiles_insert_own"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (id = (SELECT auth.uid()));

-- ---------- posts ----------
-- Public can read published posts; authors can read their drafts too.
DROP POLICY IF EXISTS "posts_select_published_or_own" ON public.posts;
CREATE POLICY "posts_select_published_or_own"
  ON public.posts
  FOR SELECT
  TO authenticated, anon
  USING (
    published = true
    OR author_id = (SELECT auth.uid())
  );

DROP POLICY IF EXISTS "posts_insert_own" ON public.posts;
CREATE POLICY "posts_insert_own"
  ON public.posts
  FOR INSERT
  TO authenticated
  WITH CHECK (author_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "posts_update_own" ON public.posts;
CREATE POLICY "posts_update_own"
  ON public.posts
  FOR UPDATE
  TO authenticated
  USING (author_id = (SELECT auth.uid()))
  WITH CHECK (author_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "posts_delete_own" ON public.posts;
CREATE POLICY "posts_delete_own"
  ON public.posts
  FOR DELETE
  TO authenticated
  USING (author_id = (SELECT auth.uid()));

-- ---------- comments ----------
DROP POLICY IF EXISTS "comments_select_all" ON public.comments;
CREATE POLICY "comments_select_all"
  ON public.comments
  FOR SELECT
  TO authenticated, anon
  USING (true);

DROP POLICY IF EXISTS "comments_insert_own" ON public.comments;
CREATE POLICY "comments_insert_own"
  ON public.comments
  FOR INSERT
  TO authenticated
  WITH CHECK (author_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "comments_update_own" ON public.comments;
CREATE POLICY "comments_update_own"
  ON public.comments
  FOR UPDATE
  TO authenticated
  USING (author_id = (SELECT auth.uid()))
  WITH CHECK (author_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "comments_delete_own" ON public.comments;
CREATE POLICY "comments_delete_own"
  ON public.comments
  FOR DELETE
  TO authenticated
  USING (author_id = (SELECT auth.uid()));

-- ---------- tags & post_tags ----------
-- Tags are a shared catalog: readable by all; writes limited to authenticated.
DROP POLICY IF EXISTS "tags_select_all" ON public.tags;
CREATE POLICY "tags_select_all"
  ON public.tags
  FOR SELECT
  TO authenticated, anon
  USING (true);

DROP POLICY IF EXISTS "tags_insert_authenticated" ON public.tags;
CREATE POLICY "tags_insert_authenticated"
  ON public.tags
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "post_tags_select_all" ON public.post_tags;
CREATE POLICY "post_tags_select_all"
  ON public.post_tags
  FOR SELECT
  TO authenticated, anon
  USING (true);

-- Only the post author may attach/detach tags on their post.
DROP POLICY IF EXISTS "post_tags_insert_post_author" ON public.post_tags;
CREATE POLICY "post_tags_insert_post_author"
  ON public.post_tags
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.posts AS p
      WHERE p.id = post_id
        AND p.author_id = (SELECT auth.uid())
    )
  );

DROP POLICY IF EXISTS "post_tags_delete_post_author" ON public.post_tags;
CREATE POLICY "post_tags_delete_post_author"
  ON public.post_tags
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.posts AS p
      WHERE p.id = post_id
        AND p.author_id = (SELECT auth.uid())
    )
  );

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Add a policy allowing post authors to DELETE comments on their own posts.
-- 2. Rewrite one policy using bare auth.uid(), then change it to
--    (select auth.uid()) and note why the select form is preferred.
-- -----------------------------------------------------------------------------

/*
-- Solutions

DROP POLICY IF EXISTS "comments_delete_post_author" ON public.comments;
CREATE POLICY "comments_delete_post_author"
  ON public.comments
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.posts AS p
      WHERE p.id = comments.post_id
        AND p.author_id = (SELECT auth.uid())
    )
  );

-- Prefer (SELECT auth.uid()) so the uid is evaluated once per statement
-- (InitPlan) instead of per-row as a volatile function call.

*/
