# 03 — CRUD Operations

Create, read, update, and delete rows with SQL first, then with `@supabase/supabase-js`.

## Learning Objectives

- Write clear `SELECT` filters, projections, and ordering
- Use `INSERT`, `UPDATE`, and `DELETE` with safe `WHERE` clauses
- Mirror the same operations in the Supabase JS client
- Always handle `{ data, error }` from the client

## Prerequisites

- Modules [`01`](../01-schema-and-alters/) and [`02`](../02-seed-data/) applied
- Optional for the TypeScript lesson: Node 18+ and `@supabase/supabase-js`

## Lessons

1. [`01-select.sql`](./01-select.sql) — reading rows
2. [`02-insert-update-delete.sql`](./02-insert-update-delete.sql) — writing rows
3. [`03-crud-with-supabase-js.ts`](./03-crud-with-supabase-js.ts) — client SDK equivalents

## Client setup tip

Use the **anon** key for learner demos once RLS is enabled (module 06). Until then, the service role bypasses RLS — never ship it to a browser.
