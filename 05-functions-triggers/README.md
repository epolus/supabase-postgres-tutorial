# 05 — Functions and Triggers

Automate `updated_at`, keep `profiles` in sync with `auth.users`, and expose PL/pgSQL helpers via `rpc`.

## Learning Objectives

- Write a reusable `updated_at` trigger function and attach it to tables
- Sync `public.profiles` when a row is inserted into `auth.users`
- Create `SECURITY DEFINER` functions with `search_path = ''` and qualified names
- Call an RPC from `@supabase/supabase-js`

## Prerequisites

- Modules [`01`](../01-schema-and-alters/)–[`04`](../04-joins-and-views/)
- Comfort reading basic PL/pgSQL (`BEGIN` / `RETURN`)

## Lessons

1. [`01-updated-at-trigger.sql`](./01-updated-at-trigger.sql) — touch `updated_at` on UPDATE
2. [`02-auth-users-sync.sql`](./02-auth-users-sync.sql) — create profile on signup
3. [`03-rpc-functions.sql`](./03-rpc-functions.sql) — callable SQL functions
4. [`04-rpc-with-supabase-js.ts`](./04-rpc-with-supabase-js.ts) — `supabase.rpc(...)`
