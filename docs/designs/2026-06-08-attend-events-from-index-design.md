# Attend events from the index — design

## Problem

Users can only become an attendee of the **featured** event, and only during onboarding (`onboarding#submit_attendance`). There's no way to mark yourself attending any other event. Meanwhile the events index lists upcoming events but offers no action on them. We want users to browse upcoming Rails events and toggle their attendance directly from the list.

This delivers the call-to-action deferred in #31 and is the upcoming-event half of #81 (retroactive past attendance stays in #81).

## Scope

- **In:** attend / un-attend **upcoming** events from the events index, one toggle per row.
- **Out (this pass):** retroactive attendance for past events (#81); a Turbo-Stream in-place toggle (v1 reloads via Turbo Drive); attendance from the event show page (#31 gate already covers show).

## Data model (unchanged)

`EventAttendance` already exists with the invariants we rely on:
- `validates :user_id, uniqueness: { scope: :event_id }` — one attendance per user per event.
- `no_overlapping_attendance` — a user cannot attend two events whose date ranges overlap.

Because attendance is unique per `user + event`, a user has **exactly one** attendance per event — so it models as a **singular** nested resource ("my attendance at this event"), needing no id in the route.

## Routes & controller

```ruby
resources :events do
  resource :attendance, only: %i[create destroy]   # POST/DELETE /events/:event_id/attendance
end
```

`AttendancesController` (nested under events; the path carries "event," so the resource is just "attendance"):

- `create` — `EventAttendance.new(user: current_user, event:)`.
  - saves → redirect to `events_path`, `notice: "You're attending #{event.name}."`
  - invalid (overlap or otherwise) → redirect to `events_path`, `alert:` with the validation message.
- `destroy` — find `current_user`'s attendance for the event, destroy, redirect to `events_path`, `notice: "You're no longer attending #{event.name}."`
- `event` (private) — `Event.find(params[:event_id])`.

`current_user` is implicit (never a route/param). Standard auth gates apply.

## View

The toggle appears only in the **Upcoming** section of the index. `_event_row` receives an explicit `attendable:` local:

- index renders `@upcoming_event_presenters` with `attendable: true`, `@past_event_presenters` with `attendable: false`.
- `attendable: false` (past) → existing read-only attendance badge, no toggle.
- `attendable: true` (upcoming):
  - attending (`event_presenter.attended_by?(current_user)`) → the "✓ You're attending" badge + a **Cancel** control (`button_to`, `DELETE`).
  - not attending → an **Attend** control (`button_to`, `POST`).

`button_to` issues the request; Turbo Drive reloads the index, so the row reflects the new state and the flash shows. Keeps the predicate as `attended_by?(current_user)` (the `attended?` viewer-aware refactor stays #82).

## Error handling

- Overlap / invalid save → flash `alert` with the model's message ("You're already attending another event that overlaps with these dates"). No switch flow.
- Unknown event id → 404 (standard `Event.find`).
- Destroy when not attending → no-op redirect (guard `find_by`).

## Testing

- **Request specs** (`AttendancesController`): attend success; un-attend success; attend blocked by overlap (flash alert, no record created); destroy when not attending (graceful).
- **System spec**: from the index, attend an upcoming event → badge appears; cancel → reverts; attempting an overlapping event shows the alert.
- **View spec** (`_event_row` / index): `attendable: true` renders the toggle; `attendable: false` renders the read-only badge.
- Model overlap/uniqueness validations already covered in `event_attendance_spec`.

## Part A — event data

Add blastoff Rails (starts in ~3 days) plus a few upcoming Rails events as **idempotent** `db/seeds.rb` entries (`find_or_create_by(name:)`), run `db:seed`. Real names/dates/locations/websites to be supplied before implementing. Note: the soonest upcoming event becomes `Event.featured` (what onboarding offers) — expected.

## Issue tracking

Closes the CTA deferred in #31; cross-links #81 (retroactive past attendance) and notes #82 (viewer-aware presenter) as still pending.
