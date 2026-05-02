# frozen_string_literal: true

module ApplicationHelper
  AVATAR_BG_CLASSES = [
    "bg-party-lavender",
    "bg-party-green",
    "bg-party-red",
    "bg-party-cyan",
  ].freeze

  AVATAR_SIZES = {
    lg: { box: "w-20 h-20", text: "text-2xl" },
    md: { box: "w-12 h-12", text: "text-base" },
    sm: { box: "w-8 h-8", text: "text-xs" },
  }.freeze

  def user_initials(user)
    parts = user.name.to_s.split
    return "" if parts.empty?
    return parts.first[0].upcase if parts.size == 1

    "#{parts.first[0]}#{parts.last[0]}".upcase
  end

  def avatar_color_class(user)
    AVATAR_BG_CLASSES[user.username.bytes.sum % AVATAR_BG_CLASSES.size]
  end

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
