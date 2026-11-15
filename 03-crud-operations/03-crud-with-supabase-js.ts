/**
 * Lesson: CRUD with @supabase/supabase-js
 * Why: After you can write the SQL, map the same ops to the client. Always
 *      destructure { data, error } and handle failures explicitly.
 *
 * Run in a small Node/TS script after setting:
 *   SUPABASE_URL, SUPABASE_ANON_KEY (or service role for pre-RLS demos)
 */

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_ANON_KEY!

const supabase = createClient(supabaseUrl, supabaseKey)

async function listPublishedPosts() {
  // SQL equivalent: SELECT ... FROM posts WHERE published = true ORDER BY created_at DESC
  const { data, error } = await supabase
    .from('posts')
    .select('id, title, slug, author_id, created_at')
    .eq('published', true)
    .order('created_at', { ascending: false })

  if (error) {
    console.error('listPublishedPosts failed:', error.message)
    return
  }

  console.log('published posts:', data)
}

async function insertDraft() {
  const { data, error } = await supabase
    .from('posts')
    .insert({
      author_id: '11111111-1111-1111-1111-111111111111',
      title: 'SDK Draft',
      slug: 'sdk-draft',
      body: 'Inserted from supabase-js',
      published: false,
    })
    .select('id, slug, published')
    .single()

  if (error) {
    console.error('insertDraft failed:', error.message)
    return
  }

  console.log('inserted:', data)
}

async function publishBySlug(slug: string) {
  // WARNING: .update() without a filter can update many rows — always filter.
  const { data, error } = await supabase
    .from('posts')
    .update({ published: true })
    .eq('slug', slug)
    .select('id, slug, published')

  if (error) {
    console.error('publishBySlug failed:', error.message)
    return
  }

  console.log('updated:', data)
}

async function deleteUnpublishedDraft(slug: string) {
  const { data, error } = await supabase
    .from('posts')
    .delete()
    .eq('slug', slug)
    .eq('published', false)
    .select('id, slug')

  if (error) {
    console.error('deleteUnpublishedDraft failed:', error.message)
    return
  }

  console.log('deleted:', data)
}

async function main() {
  await listPublishedPosts()
  await insertDraft()
  await publishBySlug('sdk-draft')
  // await deleteUnpublishedDraft('sdk-draft')
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})

/* -----------------------------------------------------------------------------
 * Practice Exercises
 * 1. Fetch profile username + display_name for alice.
 * 2. Update comment c1111111-... body via .update().eq('id', ...).
 *
 * Solutions (reference):
 *
 * const { data, error } = await supabase
 *   .from('profiles')
 *   .select('username, display_name')
 *   .eq('username', 'alice')
 *   .single()
 * if (error) console.error(error.message)
 * else console.log(data)
 *
 * const { data: updated, error: updateError } = await supabase
 *   .from('comments')
 *   .update({ body: 'Edited from the SDK' })
 *   .eq('id', 'c1111111-1111-1111-1111-111111111111')
 *   .select('id, body')
 * if (updateError) console.error(updateError.message)
 * else console.log(updated)
 * --------------------------------------------------------------------------- */
