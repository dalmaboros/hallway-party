# hallway-party

A Rails app that helps Ruby conference attendees meet each other based on their **non-programming** hobbies. Sign in with GitHub, list a few hobbies, and discover other attendees with overlapping interests via semantic (pgvector) similarity.

## Features

- GitHub OAuth sign-in
- Onboarding flow that collects a handful of non-programming hobbies per user
- Hobby canonicalization + filtering of programming-related entries
- Semantic similarity matching using OpenAI embeddings stored in pgvector
- Attendee discovery page ranked by hobby overlap to the current user

## Stack

- Ruby 4.0.3, Rails 8.1
- PostgreSQL 18 with the `pgvector` extension (via the `neighbor` gem)
- Hotwire (Turbo + Stimulus), Tailwind CSS, Propshaft, importmaps
- Solid Queue / Solid Cache / Solid Cable
- OpenAI `text-embedding-3-small` for hobby embeddings (`ruby-openai`)
- RSpec, FactoryBot, Faker, WebMock, VCR, SimpleCov
- RuboCop (Shopify config), erb_lint, Brakeman, bundler-audit, strong_migrations
- Kamal for deployment

## Getting started

### Prerequisites

- Ruby 4.0.3 (see [`.ruby-version`](.ruby-version))
- Docker (for the Postgres + pgvector container) — or a local Postgres 18 with the `pgvector` extension installed
- A GitHub OAuth app ([github.com/settings/developers](https://github.com/settings/developers))
- An OpenAI API key ([platform.openai.com/api-keys](https://platform.openai.com/api-keys))

### Setup

```sh
git clone https://github.com/dalmaboros/hallway-party.git
cd hallway-party

cp .env.example .env
# fill in GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, OPENAI_API_KEY

docker compose up -d            # starts Postgres + pgvector on :5432
bin/setup                       # bundle install, db:prepare, etc.
```

### Run the app

```sh
bin/dev
```

Then open [http://localhost:3000](http://localhost:3000).

## Tests

```sh
bundle exec rspec
```

Coverage reports are written to `coverage/` (SimpleCov). External calls to OpenAI are mocked with VCR cassettes under `spec/fixtures/vcr_cassettes/`.

## Linting and CI

The same checks GitHub Actions runs in [`.github/workflows/ci.yml`](.github/workflows/ci.yml):

```sh
bin/rubocop          # Ruby style (Shopify config)
bin/erb_lint --lint-all
bin/brakeman         # static security analysis
bin/bundler-audit    # known CVEs in gems
bin/importmap audit  # known CVEs in JS deps
```

`bin/ci` runs the full bundle locally.

## Deployment

Configured for [Kamal](https://kamal-deploy.org). See [`config/deploy.yml`](config/deploy.yml) and the `.kamal/` directory.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Issues and pull requests are welcome.

## License

[MIT](LICENSE).
