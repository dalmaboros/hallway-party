---
name: release-notes
description: Generate a CHANGELOG entry from git log between a given range. Use for tagging a release, summarizing recent work for RubyConf, or producing an update post.
disable-model-invocation: true
---

# release-notes

Generate a structured CHANGELOG entry from git history. User-only — has side effects (file writes, optional commit) and benefits from explicit invocation.

## Invocation

```
/release-notes [<rev-range>]
```

If no range is given, default to `<last-tag>..HEAD`. If no tags exist, default to `origin/main..HEAD`.

## Steps

1. **Determine range.** Use the argument if provided; otherwise:
   - `last_tag=$(git describe --tags --abbrev=0 2>/dev/null)`
   - If `last_tag` is non-empty: range is `${last_tag}..HEAD`
   - Else: range is `origin/main..HEAD`

2. **Enumerate commits.**
   ```sh
   git log --pretty=format:"%h %s%n%b---" --no-merges <range>
   ```
   Skip commits with `[skip-changelog]` anywhere in the message. Skip Dependabot bumps unless they're security or major-version.

3. **Group by area.** Infer from the dominant directory in `git show --stat <sha>` output:
   - `app/presenters/` → "Presenters"
   - `app/services/` → "Services"
   - `app/jobs/` → "Background jobs"
   - `app/controllers/` or `app/views/` → "Web"
   - `db/migrate/` → "Database"
   - `spec/` only → "Tests"
   - `.github/` or `bin/` or root config → "Tooling"
   - Anything else → "Other"

4. **Format the entry.** One H1 with the date or version, one H2 per area, bullets under each:
   ```markdown
   # 2026-05-04

   ## Presenters
   - Extract presenters from helpers (#24)
   - Apply set_x_presenter convention to onboarding and dashboard (#NN)

   ## Tooling
   - Add Claude PR Review GitHub Action (#25)
   ```
   Extract `(#N)` PR numbers from commit subjects when present.

5. **Show the draft to the user.** Do not write to disk yet. Ask:
   - Where to write it (proposed: `CHANGELOG.md` at the repo root, prepending the new entry)
   - Whether to commit, leave staged, or just print

6. **On confirmation, write and (optionally) commit.** Use the user's preferred file path. Match the existing CHANGELOG format if one exists.

## Voice

Match the project's commit-message style: imperative, present tense, no trailing period, no conventional-commit prefix. Lead with what changed, not the file list.

## Skip

- Merge commits
- Commits with `[skip-changelog]` in the body or subject
- Dependabot bumps unless security-flagged or major-version
- Pure-formatting commits (RuboCop autocorrect, whitespace) — heuristic: subject contains "rubocop", "format", "whitespace", or "lint"
