# frozen_string_literal: true

module ProfilesHelper
  # Website and Twitter are surfaced as icons in the profile header,
  # so they are intentionally excluded here to avoid duplication.
  def profile_social_links(user)
    {
      "Bluesky" => user.bluesky_url,
      "Mastodon" => user.mastodon_url,
      "LinkedIn" => user.linkedin_url,
    }.compact_blank
  end
end
