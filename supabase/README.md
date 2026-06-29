# CupPredict Supabase Database

This directory contains the production-oriented PostgreSQL schema for CupPredict.

## Files

- `migrations/20260629000000_initial_schema.sql` — normalized schema, indexes, foreign keys, RLS policies, views, functions, triggers, and stored procedures.
- `seed.sql` — deterministic public reference data for local development.

## Local usage

```bash
supabase start
supabase db reset
```

The schema references Supabase Auth via `auth.users`; application users are created through Supabase Auth and mirrored into `public.profiles`.
