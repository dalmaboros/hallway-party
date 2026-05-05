# hallway-party — Claude Code guide

## Dev server

Runs in Docker (`docker compose up`). The Rails service is named `app`. Multiple Claude instances on the same project see the same container — no coordination needed.

- `docker compose exec -T app bundle exec rspec [path]` — run specs
- `docker compose exec -T app bundle exec rails runner '<ruby>'` — smoke-test against the dev DB
- `docker compose exec -T app bin/ci` — full quality gate (RuboCop + Brakeman + bundler-audit + importmap audit)

## Review artifacts

Audits, code reviews, and ad-hoc analysis go in `docs/reviews/` (gitignored). Date-prefix filenames: `YYYY-MM-DD-<slug>.md`.

## Comment philosophy

Default to no comment. Write one only when the *why* is non-obvious — a workaround, hidden constraint, subtle invariant, or surprising behavior. A comment restating what the code does is a signal to make the code more expressive, not to annotate. Lead with the reason; keep it short.

## Layer responsibilities

- **Models** own per-entity concerns: persistence, invariants, derivations, self-queries. Workflows that span multiple entities or external systems are a different concern. Display logic lives in presenters, not models.
- **Presenters** (`app/presenters/`) wrap models and expose display-derived data — formatted dates, derived class names, computed labels, anything that's a function of model attributes shaped for the view. One presenter per model that has display logic.
- **Helpers** (`app/helpers/`) are reserved for genuinely cross-cutting view utilities not tied to any domain object (e.g. `safe_external_url`). When tempted to add a method that takes a domain object and reads its attributes, write a presenter method instead.
- **ViewComponents** are reserved for reusable UI fragments with non-trivial logic. Worth introducing once the same shape appears in three or more places.

### How presenters get to views

- **Controllers load presenters as ivars.** Each action that renders a presenter sets it via a `before_action :set_x_presenter` (mirrors the existing `set_event` pattern). Views consume `@x_presenter` directly.
- **Collections:** the controller maps the underlying query into presenters once (`@event_presenters = events.map { |e| EventPresenter.new(e) }`). Iteration sites use the presenter list, never the raw model collection.
- **Layout chrome (e.g. `_navbar`):** layouts have no owning controller, so layout partials may construct presenters inline. This is the only sanctioned exception. Document the exception in the partial.

## Embedding pipeline

Hobby ranking is semantic. `Hobby#embedding` stores a 1536-dim OpenAI vector (`text-embedding-3-small`), populated async by `GenerateHobbyEmbeddingJob` after a hobby is created. `AttendeeMatcher` uses cosine `nearest_neighbors` (via the `neighbor` gem + pgvector HNSW index) and falls back to alphabetical order when seed hobbies lack embeddings.

## Triggered patterns

Refactors deferred to specific triggers — each was accepted as "fine for now, refactor when X happens." When development hits a trigger, suggest the deferred work.

- **First concrete mailer added** → do not call mailers from model callbacks (`after_create`, etc). Mailers are infrastructure; calling them from a model couples the domain layer to outbound notifications. Trigger from a service, a job, or the controller instead.
- **Adoption of `ActiveSupport::CurrentAttributes` (`Current.user`, etc.)** → do not read `Current.*` from models or services. Pass values explicitly as parameters. `Current` is appropriate at the controller boundary (where the request lives) and nowhere below it.

## Working with these patterns

The layered-design positions in "Layer responsibilities" and "Triggered patterns" above (presenters, the `Current.*` boundary, the mailer-from-callback rule) are committed; the broader [`layered-rails`](https://github.com/palkan/skills) framework is not pre-loaded at the project level — install it locally if you want the full lens.

These rules are guidance, not enforcement. They reflect how the maintainer thinks about Rails — and they're not a rejection of other approaches. If you have a reasoned case for diverging, make it in the PR description. The pattern is a default, not a verdict.

## Agents

- [`code-reviewer`](.claude/agents/code-reviewer.md) — review checklist used by the Claude PR Review GitHub Action and `/review` locally.
