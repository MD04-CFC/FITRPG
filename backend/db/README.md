# Database

This folder contains the shared database SQL for the project.

## Structure

- `migrations/` stores ordered SQL files used to create or change database structure.
- `queries/` stores optional manual SQL, helper scripts, or analysis queries.

## Convention

- Name migration files in execution order, for example `000_init.sql`, `001_...sql`, `002_...sql`.
- Treat migrations as history. After a migration is shared, add a new file instead of rewriting the old one.
- Keep each migration focused on one clear change set.
- Use `queries/` only for SQL that is not part of the canonical schema history.
