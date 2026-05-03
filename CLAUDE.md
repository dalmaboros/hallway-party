# hallway-party — Claude Code guide

## Shared dev server (read this before starting Rails)

The Rails dev server in this repo is run inside a **shared, detached tmux session** named `hallway-party-dev`. Multiple Claude Code instances may be active in this working directory at once, so they coordinate through this single session instead of each spawning their own server on port 3000.

**Before you start the server**, check whether it is already running:

```sh
tmux has-session -t hallway-party-dev 2>/dev/null && echo running || echo stopped
```

- If it is **running**, do not start another one. You can read the current logs with:
  ```sh
  tmux capture-pane -t hallway-party-dev -p -S -200
  ```
- If it is **stopped**, start it via the `/dev-server` slash command (preferred), or directly:
  ```sh
  tmux new-session -d -s hallway-party-dev -c "$(git rev-parse --show-toplevel)" 'bin/dev'
  ```

Never run `bin/dev`, `bin/rails server`, or `foreman start` outside of this tmux session — they will collide on port 3000 with whatever the other instance is doing.

To attach interactively (and detach again with `Ctrl-b d`):
```sh
tmux attach -t hallway-party-dev
```

To stop the shared server:
```sh
tmux kill-session -t hallway-party-dev
```

## Comment philosophy

Comments should explain **why**, not what — and only when the why is non-obvious (a workaround, a hidden constraint, surprising behavior, a subtle invariant). A comment that restates what the code does is a signal the code itself could stand to be refactored to be more expressive and intention-revealing — not annotated.

Default to no comment. When one is warranted, lead with the reason and keep it short.

## Slash commands

- [`/dev-server`](.claude/commands/dev-server.md) — start or inspect the shared Rails dev server tmux session.

## Agents

- [`code-reviewer`](.claude/agents/code-reviewer.md) — review checklist used by the Claude PR Review GitHub Action and `/review` locally.
