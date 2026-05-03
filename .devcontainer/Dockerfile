# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.3
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Ensure binding is always 0.0.0.0 so Puma is reachable from outside the container.
ENV BINDING="0.0.0.0"

# The image installs Ruby via mise, but mise's shim path and the mise binary
# itself are normally added to PATH by shell init scripts — which don't run
# when compose executes `command: ...` as PID 1. The shims dir gives us
# `ruby`/`bundle`/etc.; the bin dir gives us `mise` itself, which RubyGems'
# mise plugin shells out to after every gem install (it'd error otherwise).
ENV PATH="/home/vscode/.local/share/mise/shims:/home/vscode/.local/bin:${PATH}"

# `db:prepare` shells out to `psql` to load db/structure.sql. The Rails
# devcontainer also exposes a "postgres-client" feature, but features only
# apply when VS Code builds the image — for plain `docker compose up`, we
# need psql in the base image.
USER root
RUN apt-get update && \
    apt-get install --no-install-recommends -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*
USER vscode
