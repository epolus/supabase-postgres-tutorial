# 04 — Joins and Views

Combine related tables with joins, then package common queries as views that respect RLS.

## Learning Objectives

- Write `INNER JOIN` and `LEFT JOIN` queries across posts, profiles, comments, and tags
- Choose the join type based on whether unmatched rows should disappear or stay
- Create views with `WITH (security_invoker = true)` so RLS of the underlying tables applies
- Read through a view the same way you read a table

## Prerequisites

- Modules [`01`](../01-schema-and-alters/)–[`03`](../03-crud-operations/) completed
- Seed data from module 02 present

## Lessons

1. [`01-joins.sql`](./01-joins.sql) — INNER and LEFT joins
2. [`02-views.sql`](./02-views.sql) — secure views over joined data
