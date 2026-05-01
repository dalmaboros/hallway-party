---
description: Start (or attach to) the shared Rails dev server in a tmux session so other Claude Code instances can observe it
---

You are managing a shared Rails dev server that runs inside a detached tmux session named `hallway-party-dev`. The session is intentionally shared across Claude Code instances working in this repo — never start a duplicate.

Do the following, in order, using Bash:

1. Verify tmux is installed: `command -v tmux >/dev/null || echo "MISSING"`. If missing, stop and tell the user to `brew install tmux`.

2. Check whether the session already exists:
   ```
   tmux has-session -t hallway-party-dev 2>/dev/null && echo EXISTS || echo MISSING
   ```

3. If it **exists**: capture the last 40 lines so we can confirm it is healthy:
   ```
   tmux capture-pane -t hallway-party-dev -p -S -40
   ```
   Report to the user that the session is already running, paste the tail, and remind them they can attach with `tmux attach -t hallway-party-dev` (detach with `Ctrl-b d`).

4. If it is **missing**: first run the cheap idempotent prep steps from `bin/setup` (deliberately omitting its `log:clear tmp:clear`, which would wipe logs other Claude instances may be reading), then launch `bin/dev` in a detached session from the repo root:
   ```
   bundle check >/dev/null 2>&1 || bundle install
   bin/rails db:prepare
   tmux new-session -d -s hallway-party-dev -c "$(git rev-parse --show-toplevel)" 'bin/dev'
   ```
   Then wait briefly and capture the tail to verify Puma + Tailwind both started:
   ```
   sleep 3 && tmux capture-pane -t hallway-party-dev -p -S -60
   ```
   Report startup status (look for `Listening on http://...3000` and the Tailwind watcher line).

5. End by reminding the user of the inspection commands:
   - View latest logs: `tmux capture-pane -t hallway-party-dev -p -S -200`
   - Attach interactively: `tmux attach -t hallway-party-dev`
   - Stop the server: `tmux kill-session -t hallway-party-dev`

Do **not** run `bin/dev` or `bin/rails server` outside the tmux session — that would race against the shared one on port 3000.
