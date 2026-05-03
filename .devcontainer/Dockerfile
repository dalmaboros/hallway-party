ARG RUBY_VERSION=4.0.3
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Ensure binding is always 0.0.0.0 so Puma is reachable from outside the container.
ENV BINDING="0.0.0.0"

# Compose runs `command:` as PID 1, so mise's shell-init PATH setup never
# fires. shims/ gives us `ruby`/`bundle`; bin/ gives us `mise` itself, which
# `gem install` shells out to.
ENV PATH="/home/vscode/.local/share/mise/shims:/home/vscode/.local/bin:${PATH}"

USER root
RUN apt-get update && \
    apt-get install --no-install-recommends -y postgresql-client libpq-dev && \
    rm -rf /var/lib/apt/lists/*
USER vscode
