# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    ENV.fetch("GITHUB_CLIENT_ID", nil),
    ENV.fetch("GITHUB_CLIENT_SECRET", nil),
    scope: "read:user user:email"
end

# Restrict OAuth requests to POST to prevent CSRF on sign-in
OmniAuth.config.allowed_request_methods = [:post]
