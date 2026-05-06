---
description: Review database migrations for safety against strong_migrations rules and pgvector index gotchas
---

You are reviewing newly added or modified migration files in `db/migrate/`. Apply pre-commit safety checks beyond what `strong_migrations` enforces at runtime.

## Scope

Run on any change that touches `db/migrate/`. If the diff modifies `db/schema.rb` directly without a corresponding migration, that's a `[blocking]` finding — schema.rb is auto-generated.

## What to check

### Locking and concurrency
- `add_column` with `NOT NULL` and no `default:` on a populated table → split into multiple deploys (add nullable, backfill, validate, alter to NOT NULL).
- `add_index` on a large table without `algorithm: :concurrently` → blocks writes during creation.
- `add_foreign_key` without an index on the FK column → seq scans on parent updates/deletes.
- Long-running data backfills inside the migration → should run in a separate rake task or background job.

### Drops and renames
- `remove_column`, `rename_column`, `drop_table` without a multi-deploy plan: model code referencing the column needs to deploy first.
- Removing a NOT NULL constraint while inserts could still violate it.

### pgvector specifics
- HNSW or IVFFlat index creation on `vector(N)` columns can take significant time on populated tables. Check whether `algorithm: :concurrently` is used and whether the migration is reversible.
- Changing vector dimensions on an existing column is destructive — flag for a separate PR with an explicit data-migration plan.

### Reversibility
- Migration has both `up` and `down`, or uses `change` with reversible operations only.

### `strong_migrations` opt-outs
- `safety_assured` blocks → require justification in the PR description.
- `disable_ddl_transaction!` → only acceptable for index creation with `algorithm: :concurrently`.

## What NOT to flag

- Standard column additions on small tables — `strong_migrations` already handles the threshold.
- Style — RuboCop runs in CI.
- Generic Rails migration patterns covered by `strong_migrations`'s built-in rules.

## Output

Use the same `[blocking]` / `[request]` / `[question]` / `[suggest]` labels the main `code-reviewer` agent uses (see `.claude/agents/code-reviewer.md`). If the migration looks clean, post: "Migration safety check: no concerns."
