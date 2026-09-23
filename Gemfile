# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the primary database for Active Record
gem "pg", "~> 1.1"
# SQLite for the Solid stack databases (cache, queue, cable) on a Docker volume
gem "sqlite3", "~> 2.9"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

gem "neighbor", "~> 1.0"
gem "ruby-openai", "~> 8.3"
gem "omniauth", "~> 2.1"
gem "omniauth-github", "~> 2.0"
gem "omniauth-rails_csrf_protection", "~> 2.0"
gem "strong_migrations", "~> 2.7"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :windows], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  gem "rubocop-rails", "~> 2.34", require: false
  gem "rubocop-factory_bot", "~> 2.28", require: false
  gem "rubocop-rspec", "~> 3.9", require: false
  gem "rubocop-rspec_rails", "~> 2.32", require: false
  gem "rubocop-shopify", "~> 2.18", require: false

  gem "erb_lint", "~> 0.9", require: false

  gem "dotenv-rails", "~> 3.2"
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.5"
  gem "faker", "~> 3.8"
end

group :development do
  gem "annotaterb", "~> 4.22"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Code quality metrics (Reek + Flay + Flog) [https://github.com/whitesmith/rubycritic]
  gem "rubycritic", require: false
end

group :test do
  gem "capybara", "~> 3.40"
  gem "shoulda-matchers", "~> 8.0"
  gem "webmock", "~> 3.26"
  gem "vcr", "~> 6.4"
  gem "simplecov", "~> 0.22", require: false
end
