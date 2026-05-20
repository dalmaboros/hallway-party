# Dashboard flow improvements — design

**Date:** 2026-05-19
**Status:** Approved, ready for implementation plan
**Scope:** PR 1 of 2 (dashboard restructure). PR 2 follows up with attendance toggles on `/events`.

## Goal

Reshape the signed-in dashboard around the user's next event. The current dashboard buries the upcoming event in a thin badge and shows past attendance as a separate section. The new dashboard leads with a countdown to the next event, lists all upcoming events the user is attending, and drops past events (already visible on the profile page).

## Resulting layout

```text
Dashboard

Signed in as Mona Octocat (@mona).
View profile →

┌──────────────────────────────────────┐
│ You're attending RubyConf AT         │
│ in 12 days                           │
└──────────────────────────────────────┘

Your Events                       Edit →
• RubyConf AT         Nov 5–7, 2026
• RailsConf 2026      Jul 14–16, 2026

Your Hobbies                      Edit →
[knitting] [bouldering] [sourdough]
```

Section ordering by time-sensitivity: countdown callout (most urgent) → upcoming events (broader version of the same concern) → hobbies (ongoing, not time-bound).

## Callout state machine

Three mutually exclusive states. The view branches; the state-relevant data lives on `EventPresenter`.

**State A — Event happening today** (preserved from current dashboard)
> You're at **RubyConf AT** — Day 1 of 3

Triggered when `next_event.happening_today?` is true. Uses existing `current_day` and `total_days`.

**State B — Upcoming event** (new)
> You're attending **RubyConf AT** in 12 days

Triggered when `next_event` exists and `happening_today?` is false. Uses a new `EventPresenter#days_until_start` (returns integer).

**State C — No upcoming event** (new)
> No events on your calendar — [see what's coming up](events_path)

Triggered when `current_user` has no not-past events (only past attendance). Links to the public `/events` index.

### Day-counting correctness

`days_until_start` is `(start_date - current_date).to_i`. `current_date` returns "today" in the event's time zone (existing delegated method). This matches how `current_day` already handles TZ; the existing `current_day` spec covers the edge cases (Tokyo vs UTC, Honolulu vs UTC) and we mirror them for `days_until_start`.

Singular/plural ("in 1 day" / "in 12 days") handled in the view via Rails' `pluralize` helper.

State boundaries are clean: at midnight in the event's TZ on day 1, B ("in 1 day") transitions to A ("Day 1 of N"). No special-casing.

## Controller changes

`DashboardController#index`:

```ruby
def index
  @user_presenter = UserPresenter.new(current_user)
  @hobby_presenters = current_user.hobbies.order(:name).map { |h| HobbyPresenter.new(h) }
  @upcoming_event_presenters = current_user.events.not_past.map { |e| EventPresenter.new(e) }
  @next_event_presenter = @upcoming_event_presenters.first
end
```

Three changes from the existing action:

1. Rename `@event_presenter` → `@next_event_presenter`. The name now states what it holds. Visible in three view references, all of which are being rewritten as part of this PR.
2. Add `@upcoming_event_presenters` for the Your Events list.
3. Derive `@next_event_presenter` from `@upcoming_event_presenters.first` rather than calling `current_user.next_event`. Same result — `Event.not_past` already orders by `starts_at`, so the first element of the mapped collection is the same record `User#next_event` would have returned. One fewer query.

## Presenter changes

Two new methods on `EventPresenter`:

```ruby
def days_until_start
  (start_date - current_date).to_i
end

def short_date_range
  if start_date == end_date
    start_date.strftime("%b %-d, %Y")
  elsif start_date.year == end_date.year && start_date.month == end_date.month
    "#{start_date.strftime("%b %-d")}–#{end_date.day}, #{end_date.year}"
  else
    "#{start_date.strftime("%b %-d, %Y")} – #{end_date.strftime("%b %-d, %Y")}"
  end
end
```

`short_date_range` mirrors the existing `date_range` branch-for-branch, swapping `%B` (full month name) for `%b` (abbreviated). Used only on the dashboard; existing `date_range` continues serving `events/show`, `events/index`, and `onboarding/welcome` where there's room for the long format.

## Removals

- **"Past events" section** is deleted from the dashboard. Past attendance remains visible on the profile page (already implemented at `profiles/show.html.erb`). Dashboard becomes forward-looking only.
- **`User#next_event`** is deleted. After the controller rewrite, no production caller remains. The three test cases in `spec/models/user_spec.rb` for `#next_event` are deleted with it. The derived value moves to the controller (`@upcoming_event_presenters.first`).
- **"Your hobbies"** heading capitalization → **"Your Hobbies"**. Title-case consistency with "Your Events".

## Profile link

Renders as a small text link directly under the "Signed in as ..." sentence. Destination: `/profiles/:username`. Action verb is "View profile" rather than "Edit profile" because no profile-edit UI exists per MVP scope (user fields are sourced from GitHub via the resolver).

## Out of scope

Deferred to PR 2:

- Attendance toggles on `/events`: each event card gains a "Going / Not going" toggle, making the index page a real management surface. Interaction design (Turbo Stream optimistic update, confirmation on "Leave event", `EventAttendance` deletion semantics) gets its own brainstorm pass when PR 2 starts.

In the gap between PR 1 and PR 2, the dashboard's "Edit" link on Your Events points at `/events` as-is. The link is functional (the user can browse and click into individual events to manage attendance per-event) but doesn't yet feel like a personal manage page.

Not in scope at all:

- Profile-edit UI. The MVP constraint that user fields source from GitHub still holds; revisit when multi-conference support is added or when first-class user-managed profile data becomes a priority.

## Testing

**Presenter specs** (extend `spec/presenters/event_presenter_spec.rb`):

- `#days_until_start` — happy path (event in N days), boundary case (event starts today returns 0 — though this state is filtered by `happening_today?` in the view), TZ correctness mirroring the existing `#current_day` TZ tests (Tokyo, Honolulu).
- `#short_date_range` — four branches matching the existing `date_range` describe block (same day, same month, cross-month, cross-year).

**Request specs** (extend dashboard request spec — `spec/requests/dashboards_spec.rb` if it exists, else create):

- State A: user attending an in-progress event → page contains "Day X of Y".
- State B: user has only future event → page contains "in N days" (and event name appears in the callout).
- State C: user has only past attendance → page contains "No events on your calendar" and a link to `events_path`.
- Section ordering: callout appears above Your Events appears above Your Hobbies.

**User spec deletions:**

- Remove `describe "#next_event"` block from `spec/models/user_spec.rb` (3 examples).

## Decisions log

Why-trace for future readers.

**Past events moves to profile (not dashboard).** Considered: keeping past events as a third dashboard section, or grouping past+upcoming under "Your Events". Chose profile-only because the dashboard's job is forward orientation (what's next), and past attendance already has a home on the profile page. Avoids duplicating the same data in two places, drives more profile-page traffic.

**Empty-state callout shows a browse-events CTA.** Considered: hiding the callout entirely when no upcoming event, or showing backward-facing "Your last event was X" copy. Chose the CTA because the user reaching the dashboard with only past attendance is a re-engagement opportunity — pointing them at upcoming events is the highest-value next step.

**Profile link reads "View profile" not "Edit profile".** The user requested "Edit" for consistency with the other section links (Edit Hobbies, Edit Events). Rejected because there is no profile-edit UI to point at, and the MVP explicitly excludes building one. "View profile" is honest about what's possible. Action-verb inconsistency is acceptable; broken-link consistency is not.

**Edit Events link goes to `/events` (with toggles arriving in PR 2).** Considered: building a new `/onboarding/events` manage page mirroring `/onboarding/hobbies`, or dropping the Edit link until a destination exists. Chose `/events` with toggles because the events index already lists upcoming events, and augmenting it with attendance toggles produces a discovery-and-management surface in one page rather than a separate manage page. Keeps URL surface small.

**Split into two PRs rather than one big PR.** PR 1 = dashboard restructure, PR 2 = `/events` attendance toggles. Each PR has one clear story; reviewers can evaluate the dashboard UX changes independently from the toggle interaction design (which has its own design surface). The cost is a brief "Edit link is awkward" window between the PRs.

**Compact `short_date_range` is a new presenter method, not a parameter on `date_range`.** Two formats = two methods is fine; refactor to `date_range(:short)` only if a third format appears. Avoids premature abstraction.

**`@event_presenter` renamed to `@next_event_presenter`.** With `@upcoming_event_presenters` (plural list) added in the same action, the generic `@event_presenter` no longer carries the right semantics. The rename makes the singular/plural pair self-documenting.
