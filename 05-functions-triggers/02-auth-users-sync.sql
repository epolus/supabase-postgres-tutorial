-- =============================================================================
-- Lesson: Sync public.profiles from auth.users on signup
-- Why: Every new Auth user should get a profile row automatically so FKs and
--      RLS on posts/comments keep working.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Why SECURITY DEFINER: auth.users insert runs as a privileged role; we still
  -- lock search_path and write only to public.profiles with qualified names.
  INSERT INTO public.profiles (id, username, display_name)
  VALUES (
    NEW.id,
    -- Fall back to the first email local-part when raw_user_meta_data lacks username
    COALESCE(
      NEW.raw_user_meta_data ->> 'username',
      split_part(NEW.email, '@', 1)
    ),
    COALESCE(
      NEW.raw_user_meta_data ->> 'display_name',
      NEW.raw_user_meta_data ->> 'username',
      split_part(NEW.email, '@', 1)
    )
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Optional smoke test (local/tutorial only): insert a throwaway auth user and
-- confirm a profile appears. Clean up afterward if you run this.
-- WARNING: touches auth.users — skip on shared production projects.
/*
INSERT INTO auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
) VALUES (
  '44444444-4444-4444-4444-444444444444',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'dana@example.com',
  crypt('password123', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"username":"dana","display_name":"Dana"}'::jsonb,
  now(), now(),
  '', '', '', ''
);

SELECT id, username, display_name
FROM public.profiles
WHERE id = '44444444-4444-4444-4444-444444444444';
*/

-- -----------------------------------------------------------------------------
-- Practice Exercises
-- 1. Extend handle_new_user to copy bio from raw_user_meta_data->>'bio' when set.
-- 2. Explain why ON CONFLICT DO NOTHING is useful if you also seed profiles.
-- -----------------------------------------------------------------------------
-- Hints: see HINTS.md · Solutions: see ANSWERS.md (same lesson path).
