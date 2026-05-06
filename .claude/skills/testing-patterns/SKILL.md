---
name: testing-patterns
description: RSpec testing philosophy, mocking strategy, and TDD discipline for hallway-party. Use when writing specs, refactoring tests, or reviewing test coverage.
---

# Testing patterns

## Philosophy

### TDD: red → green → refactor

- Write the failing spec **first**.
- Implement the minimum to make it pass.
- Refactor after green.

The discipline matters: tests written after the code can pass for the wrong reasons. A spec that doesn't actually exercise the behavior is a false positive — it lets bugs through while creating the illusion of coverage.

### Behavior is the subject's responsibility — contextually

"Test behavior, not implementation" is too easy to misapply. Behavior depends on what the subject is responsible for **and** what spec type you're in:

- In a unit spec for `User#subscribe!`, creating a `Subscription` record **is** the behavior — that's the method's job.
- In a request spec for `POST /subscriptions`, the same side effect is implementation detail — the user-facing behavior is the response (status, redirect, body shape).

Before writing the assertion, ask: "what is this subject responsible for delivering to its caller?" That's what to assert on.

### Mock at boundaries; hit the DB everywhere else

- **Internal collaborators: don't mock.** Use real records via FactoryBot. Mocking a model method to test a service that calls it tests the wiring, not the behavior — and breaks under refactoring.
- **External services** (OpenAI, GitHub OAuth, Stripe, mailers): always stub. You can't hit real APIs in tests — cost, flakiness, network.

### Brittle is the enemy

A spec is brittle when it fails on implementation changes that don't change behavior. The gut-check before committing: *"what production change would make this fail in a way I'd want it to fail?"* If the answer is "only an implementation change, not a behavior change," the spec is brittle — rewrite it to assert on the observable outcome instead.

## Spec types

### Request specs — default for HTTP routes

Use for anything testable through the HTTP layer: endpoints, redirects, response bodies, status codes, JSON shape. Cheap, fast, adequate for most controller behavior. **Reach for these first.**

### System specs — for UX/interactivity OR end-to-end smoke

Use for user-facing flows where JS or visual outcome matters, **or** full-stack smoke tests for critical paths. Slow, more brittle, costlier to write — reach for them deliberately, not by default.

### Model / service / form-object specs — unit-level

Use for business logic, validations, side effects, edge cases. Hit the real DB via FactoryBot. Don't stub internal collaborators.

### Job specs (Solid Queue)

Use for background-job behavior: what `perform` does, idempotency on retry, error handling, retry/discard semantics. Test the public interface — `perform` — not the internal call sequence.

## External service stubbing

Two common approaches; pick based on what you're testing:

**Wrap the third-party gem in your own client.** Tests stub the wrapper. When the upstream gem changes, you update one place.

```ruby
# Production:
class Embedder
  def embed(text) = OpenAI::Client.new.embed(input: text)
end

# Test:
allow_any_instance_of(Embedder).to receive(:embed).and_return([0.1, 0.2, ...])
```

**WebMock at the HTTP layer.** Use when the spec is specifically about how you talk to the external service — payload shape, content type, error handling.

```ruby
stub_request(:post, "https://api.openai.com/v1/embeddings")
  .to_return(status: 200, body: { data: [{ embedding: [...] }] }.to_json)
```

In practice: stub at the wrapper for most app-logic tests; reach for WebMock when verifying the integration itself.

## Open questions

The conventions below haven't been decided yet — defer to existing patterns in the codebase, and add to this file once a consistent approach emerges:

- FactoryBot trait / sequence / transient-attribute conventions
- Spec naming style (descriptive sentences vs technical phrases)
- Test scope (strict one-behavior-per-`it` vs grouped assertions)
- Coverage target
- When to introduce shared examples / contexts
- Time helpers convention (`freeze_time` vs `Timecop` vs ad-hoc stubbing)
