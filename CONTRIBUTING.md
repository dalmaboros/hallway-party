# Contributing to hallway-party

Thanks for your interest! Contributions from first-time contributors are especially welcome.

## Code of conduct

Be kind. This project follows the spirit of the [Contributor Covenant](https://www.contributor-covenant.org/). Harassment, discrimination, and disrespectful behavior are not tolerated. If something feels off, open a private issue or email the maintainer.

## Getting set up

Follow the [Getting started](README.md#getting-started) section of the README. The fastest path is `docker compose up` — the only host requirement is Docker.

You're ready when the app loads at [http://localhost:3000](http://localhost:3000) and the test suite passes:

```sh
# inside the dev container (VS Code terminal):
bundle exec rspec

# from the host, with `docker compose up` running:
docker compose exec app bundle exec rspec
```

If something is broken in the setup steps, that's a bug — please open an issue.

## Picking something to work on

- Browse [open issues](https://github.com/dalmaboros/hallway-party/issues), especially those labeled `good first issue` or `help wanted`.
- For bigger changes, open an issue first to discuss the approach before writing code.
- For small fixes (typos, tests, copy), feel free to send a PR directly.

## Workflow

1. Fork the repo and create a topic branch off `main` (e.g. `fix/onboarding-typo`, `feat/event-rsvp`).
2. Make your change.
3. Run the checks below locally.
4. Open a pull request against `main`. Reference the issue it closes (if any) in the description.

CI must pass before a PR is merged.

## Local checks

Before pushing, run (prefix with `docker compose exec app` if running outside the dev container):

```sh
bundle exec rspec
bin/rubocop
bin/erb_lint --lint-all
bin/brakeman
bin/bundler-audit
```

Or run the whole bundle with `bin/ci`.

## Coding conventions

- Ruby style follows [`rubocop-shopify`](https://github.com/Shopify/ruby-style-guide). Run `bin/rubocop -A` to autocorrect what's safe.
- ERB templates are linted with `erb_lint`.
- Migrations are checked by `strong_migrations` — please don't bypass it without a comment explaining why.
- Embedding generation runs in a Solid Queue background job; never block a request on the OpenAI API.
- Hobby-related logic should not embed user profiles — only individual hobby strings get vector embeddings. See the architecture notes in [`confapp-planning/`](../confapp-planning/) (if present in your checkout) for context.

## Tests

- New features need tests. Bug fixes should include a regression test.
- External HTTP is mocked with WebMock + VCR. Do not commit cassettes that contain real API keys; check the diff before pushing.
- Aim to keep the test suite fast and deterministic.

## Commits and PRs

- Write commit messages in the imperative ("Add hobby filter", not "Added hobby filter").
- Squash noisy WIP commits before opening the PR if you can.
- Keep PRs focused — smaller is easier to review.

## Requesting an automated review

Apply the `claude-review` label to your PR to trigger an automated code review. The reviewer follows the checklist in [`.claude/agents/code-reviewer.md`](.claude/agents/code-reviewer.md) and the principles in [`CLAUDE.md`](CLAUDE.md), and posts a single comment grouped by severity (`[blocking]` / `[request]` / `[question]` / `[suggest]`) within about a minute.

The review re-runs on subsequent pushes while the label is applied. Remove the label to stop further reviews.

## Questions?

Open a discussion or an issue on GitHub.
