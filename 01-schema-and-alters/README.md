# 01 — Schema and Alters

Design the core tables for a simple blog: profiles, posts, comments, tags, and the post–tag junction.

## Learning Objectives

- Create tables with `uuid` primary keys, foreign keys, and `created_at` timestamps
- Evolve a schema safely with `ALTER TABLE` (`IF EXISTS` / `IF NOT EXISTS`)
- Add constraints (NOT NULL, UNIQUE, CHECK) and useful indexes
- Understand when to warn about data impact before destructive changes

## Prerequisites

- Access to a Supabase project SQL Editor (or local Postgres with `pgcrypto` / `gen_random_uuid()` available)
- No prior modules required — this is the starting point

## Lessons

1. [`01-create-tables.sql`](./01-create-tables.sql) — create the domain tables
2. [`02-alter-tables.sql`](./02-alter-tables.sql) — safe column adds and renames
3. [`03-constraints-and-indexes.sql`](./03-constraints-and-indexes.sql) — constraints and indexes

Run the files in order in the SQL Editor.
