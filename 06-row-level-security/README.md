# 06 — Row Level Security

Turn on RLS and write policies so PostgREST only returns (and mutates) rows each user is allowed to touch.

## Learning Objectives

- `ENABLE ROW LEVEL SECURITY` on every exposed table
- Write `CREATE POLICY` rules for SELECT / INSERT / UPDATE / DELETE
- Prefer `(select auth.uid())` over bare `auth.uid()` for plan performance
- Separate “public read” from “owner write” patterns on posts and comments

## Prerequisites

- Modules [`01`](../01-schema-and-alters/)–[`05`](../05-functions-triggers/)
- Understanding that the `anon` / `authenticated` roles hit your tables via the API

## Lessons

1. [`01-enable-rls.sql`](./01-enable-rls.sql) — enable RLS (and what happens if you stop there)
2. [`02-create-policies.sql`](./02-create-policies.sql) — practical policies for the blog model

## Important reminder

With RLS enabled and **no** policies, the table looks empty (and rejects writes) for `anon` / `authenticated`. Always add policies in the same change as `ENABLE ROW LEVEL SECURITY`.
