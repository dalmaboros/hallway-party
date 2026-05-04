# frozen_string_literal: true

class UserPresenter
  AVATAR_BG_CLASSES = [
    "bg-party-lavender",
    "bg-party-green",
    "bg-party-red",
    "bg-party-cyan",
  ].freeze

  attr_reader :user

  delegate :name, :username, :avatar_url, :hobbies, to: :user

  def initialize(user)
    @user = user
  end

  def initials
    parts = name.to_s.split
    return "" if parts.empty?
    return parts.first[0].upcase if parts.size == 1

    "#{parts.first[0]}#{parts.last[0]}".upcase
  end

  def avatar_color_class
    AVATAR_BG_CLASSES[username.bytes.sum % AVATAR_BG_CLASSES.size]
  end
end
