# hallway-party — Claude Code guide

## Conventions checklist (verify the diff before claiming done)

Before declaring any task complete, check the changed code against each item and fix violations.

- [ ] **Presenter ivars are suffixed** — `@x_presenter` / `@x_presenters`, never a bare `@x`. The name must say it's a presenter, not imply a raw model/collection.
- [ ] **No logic in views** — no `<% x = … %>` assignments and no derivation in ERB. Computed/derived values come from a presenter method. Views only branch on and print presenter output.
- [ ] **Partials use strict locals** — every partial opens with `<%# locals: (…) %>` and receives data as locals, never by reaching for controller ivars.
- [ ] **Display logic lives in presenters; domain derivations on the model** — not in controllers (which only wire) or views. (See "Layer responsibilities".)
- [ ] **Single-record lookups are nil-guarded before wrapping** — `EventPresenter.new(nil)` is truthy and breaks `if`-presence checks; guard so the absent case stays `nil`.
- [ ] **Method names read standalone** — a name must carry its meaning without leaning on its argument list (`event_presenter(x)`, not `wrap(x)`).
- [ ] **Names keep the head noun** — prefer the full concept over a bare qualifier: `upcoming_events` / `past_events`, not `upcoming` / `past`. A variable, keyword arg, or method name should say *what it holds*, not just an adjective that leans on context.
- [ ] **Comments only for non-obvious *why*** — never restate what the code does.
- [ ] **No temporary variables** — inline a value at its single use, or extract a method; reach for a local only to name a sub-expression reused within one cohesive method. In specs, hoist shared setup to `let` rather than a per-example local. Applies everywhere, not just tests.
- [ ] **Model specs use shoulda-matchers one-liners** — associations and validations are `it { is_expected.to … }` under `describe "associations"` / `describe "validations"`; one `describe "#method"` block per instance method.
- [ ] **Implicit keyword-argument value syntax** — write `foo(bar:)`, not `foo(bar: bar)`, when a same-named binding is in scope.

## Dev server

Runs in Docker (`docker compose up`). The Rails service is named `app`. Multiple Claude instances on the same project see the same container — no coordination needed.

- `docker compose exec -T app bundle exec rspec [path]` — run specs
- `docker compose exec -T app bundle exec rails runner '<ruby>'` — smoke-test against the dev DB
- `docker compose exec -T app bin/ci` — full quality gate (RuboCop + Brakeman + bundler-audit + importmap audit)

## Review artifacts

Audits, code reviews, and ad-hoc analysis go in `docs/reviews/` (gitignored). Date-prefix filenames: `YYYY-MM-DD-<slug>.md`.

## Styling

Tailwind CSS. Chosen for the collaborative context — utility classes give every contributor a shared, predictable styling vocabulary regardless of their CSS background.

## Comment philosophy

Default to no comment. Write one only when the *why* is non-obvious — a workaround, hidden constraint, subtle invariant, or surprising behavior. A comment restating *what* the code does is a signal the code should be made more expressive, not annotated. Lead with the reason; keep it short.

## Layer responsibilities

- **Models** own per-entity concerns: persistence, invariants, derivations, self-queries. Workflows that span multiple entities or external systems are a different concern. Display logic lives in presenters, not models.
- **Presenters** (`app/presenters/`) wrap models and expose display-derived data — formatted values, derived class names, computed labels. One presenter per model that has display logic.
- **Helpers** (`app/helpers/`) are reserved for genuinely cross-cutting view utilities not tied to any domain object. When tempted to add a helper that takes a domain object and reads its attributes, write a presenter method instead.
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
