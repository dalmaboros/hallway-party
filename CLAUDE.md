# hallway-party — Claude Code guide

## Dev server

Runs in Docker (`docker compose up`). Multiple Claude instances on the same project see the same container — no coordination needed.

## Comment philosophy

Comments should explain **why**, not what — and only when the why is non-obvious (a workaround, a hidden constraint, surprising behavior, a subtle invariant). A comment that restates what the code does is a signal the code itself could stand to be refactored to be more expressive and intention-revealing — not annotated.

Default to no comment. When one is warranted, lead with the reason and keep it short.

## Agents

- [`code-reviewer`](.claude/agents/code-reviewer.md) — review checklist used by the Claude PR Review GitHub Action and `/review` locally.
