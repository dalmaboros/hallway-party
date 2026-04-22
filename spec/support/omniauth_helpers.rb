# frozen_string_literal: true

module OmniAuthHelpers
  # Returns an OmniAuth::AuthHash suitable for passing directly to a service
  # or for use as mock middleware state. Pass overrides to customize per-test.
  def github_auth_hash(**overrides)
    default_auth = {
      provider: "github",
      uid: "12345",
      info: {
        nickname: "octocat",
        name: "Mona Octocat",
        email: "mona@github.com",
        image: "https://example.com/avatar.png",
      },
      extra: {
        raw_info: {
          location: "San Francisco",
          pronouns: "she/her",
        },
      },
    }

    OmniAuth::AuthHash.new(default_auth.deep_merge(overrides))
  end

  # Configures OmniAuth middleware to return the mock auth hash on the
  # `/auth/github/callback` route. Use in request/system specs.
  def stub_github_auth(**overrides)
    OmniAuth.config.test_mode = true
    auth = github_auth_hash(**overrides)
    OmniAuth.config.mock_auth[:github] = auth
    Rails.application.env_config["omniauth.auth"] = auth
    auth
  end

  def clear_github_auth
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:github] = nil
    Rails.application.env_config["omniauth.auth"] = nil
  end
end

RSpec.configure do |config|
  config.include OmniAuthHelpers
end
