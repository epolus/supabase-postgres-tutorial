# Supabase PostgreSQL Database Tutorial

A progressive, hands-on tutorial for learning PostgreSQL through Supabase. Each module builds on the last using one consistent domain model: **profiles**, **posts**, **comments**, **tags**, and **post_tags**.

## Who this is for

Beginners who can run SQL in the Supabase SQL Editor (or `psql`) and want production-minded habits: safe migrations, RLS, secure views, and the JS client.

## How to work through the modules

1. Open your Supabase project → **SQL Editor**.
2. Start with module `01` and run the lesson files in numeric order.
3. Read each module’s `README.md` for **Learning Objectives** and **Prerequisites**.
4. Try the **Practice Exercises** at the end of each lesson. If stuck, peek at [`HINTS.md`](./HINTS.md); full solutions are in [`ANSWERS.md`](./ANSWERS.md).
5. When a lesson shows both SQL and TypeScript, learn the SQL first, then the `@supabase/supabase-js` equivalent.

| Module | Topic |
|--------|--------|
| [`01-schema-and-alters/`](./01-schema-and-alters/) | Tables, alters, constraints, indexes |
| [`02-seed-data/`](./02-seed-data/) | Idempotent mock data |
| [`03-crud-operations/`](./03-crud-operations/) | SELECT / INSERT / UPDATE / DELETE (SQL + SDK) |
| [`04-joins-and-views/`](./04-joins-and-views/) | Joins and secure views |
| [`05-functions-triggers/`](./05-functions-triggers/) | PL/pgSQL functions, triggers, rpc |
| [`06-row-level-security/`](./06-row-level-security/) | RLS policies |

## Domain model (overview)

```text
auth.users ──< profiles
profiles ──< posts ──< comments
posts >──< tags   (via post_tags)
```

- `profiles.id` matches `auth.users.id` (uuid).
- Posts and comments belong to a profile (author).
- Tags attach to posts through `post_tags`.

## Conventions used here

- SQL keywords `UPPERCASE`; identifiers `snake_case`
- `uuid` primary keys with `gen_random_uuid()`; `created_at timestamptz`
- Inline `--` comments that explain *why*
- RLS with `(select auth.uid())`; views with `security_invoker = true`
- `SECURITY DEFINER` functions set `search_path = ''`

## Prerequisites

- A free [Supabase](https://supabase.com) project (or local Supabase CLI stack)
- Basic comfort with a code editor
- Optional for SDK lessons: Node.js 18+ and `@supabase/supabase-js`

## License

See [LICENSE](./LICENSE).
