# frozen_string_literal: true

module ApplicationHelper
  AVATAR_SIZES = {
    lg: { box: "w-20 h-20", text: "text-2xl" },
    md: { box: "w-12 h-12", text: "text-base" },
    sm: { box: "w-8 h-8", text: "text-xs" },
  }.freeze

  def avatar_size_classes(size)
    AVATAR_SIZES.fetch(size)
  end

  # Returns the URL only if it parses as an http(s) URL, else nil.
  # Use whenever rendering a user- or admin-supplied URL into an href to
  # prevent javascript: and data: scheme XSS.
  def safe_external_url(url)
    url if url.to_s.match?(%r{\Ahttps?://}i)
  end
end
