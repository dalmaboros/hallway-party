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

## Comment philosophy

Comments should explain **why**, not what — and only when the why is non-obvious (a workaround, a hidden constraint, surprising behavior, a subtle invariant). A comment that restates what the code does is a signal the code itself could stand to be refactored to be more expressive and intention-revealing — not annotated.

Default to no comment. When one is warranted, lead with the reason and keep it short.

## Agents

- [`code-reviewer`](.claude/agents/code-reviewer.md) — review checklist used by the Claude PR Review GitHub Action and `/review` locally.