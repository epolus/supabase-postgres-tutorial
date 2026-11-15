# 02 — Seed Data

Load idempotent mock rows so you can practice queries without clicking through the Auth UI every time.

## Learning Objectives

- Write `INSERT ... ON CONFLICT` seeds that are safe to re-run
- Seed related tables in dependency order (auth → profiles → posts → comments / tags)
- Use stable uuids so later modules can reference the same rows
- Understand why seeding `auth.users` is a **local/dev** convenience, not a production habit

## Prerequisites

- Complete [`01-schema-and-alters/`](../01-schema-and-alters/) (tables, slug column, constraints)
- A Supabase project where you can run SQL (Dashboard SQL Editor is fine)

## Lessons

1. [`01-seed-auth-and-profiles.sql`](./01-seed-auth-and-profiles.sql) — stub users + profiles
2. [`02-seed-posts-comments-tags.sql`](./02-seed-posts-comments-tags.sql) — posts, comments, tags, junction

Run in order. Re-running should not duplicate rows.
