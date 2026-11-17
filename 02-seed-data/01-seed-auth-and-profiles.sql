-- =============================================================================
-- Lesson: Idempotent seed for auth.users + public.profiles
-- Why: profiles.id references auth.users(id). Stable uuids let every module
--      talk about the same demo authors.
--
-- WARNING: Inserting into auth.users is for local / tutorial projects only.
--          Prefer the Auth Admin API or Dashboard in real environments.
-- =============================================================================

-- Fixed demo identities (do not change once other lessons reference them).
-- alice: 11111111-1111-1111-1111-111111111111
-- bob:   22222222-2222-2222-2222-222222222222

-- Minimal auth.users rows. Many columns have defaults; we set the ones Auth
-- and our FK expect so profile inserts succeed.
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'alice@example.com',
    crypt('password123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"username":"alice"}'::jsonb,
    now(),
    now(),
    '',
    '',
    '',
    ''
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'bob@example.com',
    crypt('password123', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"username":"bob"}'::jsonb,
    now(),
    now(),
    '',
    '',
    '',
    ''
  )
ON CONFLICT (id) DO NOTHING;

-- Profiles: ON CONFLICT keeps re-seeds from failing on username / id.
INSERT INTO public.profiles (id, username, display_name, bio)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'alice',
    'Alice Anderson',
    'Writes about databases and tea.'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'bob',
    'Bob Baker',
    'Likes indexes more than cake.'
  )
ON CONFLICT (id) DO UPDATE
SET
  display_name = EXCLUDED.display_name,
  bio = EXCLUDED.bio;

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Seed a third user + profile (carol) with a new fixed uuid.
-- 2. Make the profile upsert also refresh username from EXCLUDED.
-- -----------------------------------------------------------------------------
-- Hints: see HINTS.md · Solutions: see ANSWERS.md (same lesson path).
