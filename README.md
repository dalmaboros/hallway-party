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

The project is fully containerized — Docker is the only host requirement. Pick whichever workflow you prefer:

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Compose v2)
- A GitHub OAuth app ([github.com/settings/developers](https://github.com/settings/developers))
- An OpenAI API key ([platform.openai.com/api-keys](https://platform.openai.com/api-keys))

### Option 1 — `docker compose up` (any editor)

```sh
git clone https://github.com/dalmaboros/hallway-party.git
cd hallway-party

cp .env.example .env
# fill in GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, OPENAI_API_KEY

docker compose up
```

The first boot installs gems and prepares the database (~1–2 minutes). Subsequent boots are fast.

App: [http://localhost:3000](http://localhost:3000) · Health check: [/up](http://localhost:3000/up) · Build info: [/version](http://localhost:3000/version).

### Option 2 — VS Code Dev Container

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Clone the repo and open it in VS Code.
3. When prompted, pick "Reopen in Container" (or run "Dev Containers: Reopen in Container" from the command palette).
4. After the container builds, run `bin/dev` from the integrated terminal.

The dev container shares volumes with `docker compose up`, so gems and the database carry over between the two flows.

### Native (non-Docker) development

If you'd rather run Rails on your host: install Ruby 4.0.3, install Postgres 18 with the `pgvector` extension, then run `bin/setup` followed by `bin/dev`. The container flows above are recommended for new contributors.

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
