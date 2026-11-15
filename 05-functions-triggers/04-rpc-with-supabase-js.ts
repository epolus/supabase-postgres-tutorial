/**
 * Lesson: Call Postgres functions with supabase.rpc
 * Why: Keep heavy or multi-row logic in SQL; invoke it from the client with
 *      the same { data, error } handling as table queries.
 */

import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
)

async function countAlicePublished() {
  // SQL: SELECT public.count_published_posts_for('alice');
  const { data, error } = await supabase.rpc('count_published_posts_for', {
    username: 'alice',
  })

  if (error) {
    console.error('count_published_posts_for failed:', error.message)
    return
  }

  console.log('alice published count:', data)
}

async function publishMyDrafts() {
  // Requires a signed-in user; auth.uid() must match posts.author_id
  const { data, error } = await supabase.rpc('publish_my_drafts')

  if (error) {
    console.error('publish_my_drafts failed:', error.message)
    return
  }

  console.log('published drafts:', data)
}

async function main() {
  await countAlicePublished()
  // await publishMyDrafts()
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})

/* -----------------------------------------------------------------------------
 * Practice Exercises
 * 1. Call latest_posts with limit_count: 5 (after creating it in 03).
 * 2. Log a clear message when error is non-null vs when data is empty.
 *
 * Solutions (reference):
 *
 * const { data, error } = await supabase.rpc('latest_posts', { limit_count: 5 })
 * if (error) {
 *   console.error('latest_posts failed:', error.message)
 * } else if (!data?.length) {
 *   console.log('No published posts yet')
 * } else {
 *   console.log(data)
 * }
 * --------------------------------------------------------------------------- */
