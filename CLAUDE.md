# hallway-party — Claude Code guide

## Dev server

Runs in Docker (`docker compose up`). Multiple Claude instances on the same project see the same container — no coordination needed.

## Layer responsibilities

- **Models** model the persistence layer. They own DB access, validations, associations, and business invariants. They do **not** own display logic.
- **Presenters** (`app/presenters/`) wrap models and expose display-derived data — formatted dates, derived class names, computed labels, anything that's a function of model attributes shaped for the view. One presenter per model that has display logic.
- **Helpers** (`app/helpers/`) are reserved for genuinely cross-cutting view utilities not tied to any domain object (e.g. `safe_external_url`). When tempted to add a method that takes a domain object and reads its attributes, write a presenter method instead.
- **ViewComponents** are reserved for reusable UI fragments with non-trivial logic. Worth introducing once the same shape appears in three or more places.

### How presenters get to views

- **Controllers load presenters as ivars.** Each action that renders a presenter sets it via a `before_action :set_x_presenter` (mirrors the existing `set_event` pattern). Views consume `@x_presenter` directly.
- **Collections:** the controller maps the underlying query into presenters once (`@event_presenters = events.map { |e| EventPresenter.new(e) }`). Iteration sites use the presenter list, never the raw model collection.
- **Layout chrome (e.g. `_navbar`):** layouts have no owning controller, so layout partials may construct presenters inline. This is the only sanctioned exception. Document the exception in the partial.

## Triggered patterns

Architectural decisions deferred to specific triggers. When a PR (or development work) appears to hit one of these triggers, suggest the deferred refactor. Each was accepted in the architecture audit as "fine for now, refactor when X happens."

- **Second OAuth provider added** → generalize `GithubUserResolver` (e.g. `OAuthResolver.new(auth_hash, provider:)` or per-provider classes sharing a base).
- **Third user-card-shaped partial** (after `_avatar`, `_attendee`) → promote to a ViewComponent with a shared base.
- **Event listing query growing beyond `Event.active.order(:starts_at)`** → formalize an `app/queries/` directory before scopes accumulate.
- **Second anemic job** (a single-line `perform` that just delegates to a model method) → consider the `active_job-performs` gem to fold the wrapper into the model class.
- **First concrete mailer added** → do not call mailers from model callbacks (`after_create`, etc). Mailers are infrastructure; calling them from a model couples the domain layer to outbound notifications. Trigger from a service, a job, or the controller instead.
- **Adoption of `ActiveSupport::CurrentAttributes` (`Current.user`, etc.)** → do not read `Current.*` from models or services. Pass values explicitly as parameters. `Current` is appropriate at the controller boundary (where the request lives) and nowhere below it.

## Comment philosophy

Comments should explain **why**, not what — and only when the why is non-obvious (a workaround, a hidden constraint, surprising behavior, a subtle invariant). A comment that restates what the code does is a signal the code itself could stand to be refactored to be more expressive and intention-revealing — not annotated.

Default to no comment. When one is warranted, lead with the reason and keep it short.

## Agents

- [`code-reviewer`](.claude/agents/code-reviewer.md) — review checklist used by the Claude PR Review GitHub Action and `/review` locally.