# frozen_string_literal: true

class UserPresenter
  AVATAR_BG_CLASSES = [
    "bg-party-lavender",
    "bg-party-green",
    "bg-party-red",
    "bg-party-cyan",
  ].freeze

  attr_reader :user

  delegate :name,
    :username,
    :avatar_url,
    :hobbies,
    :bio,
    :pronouns,
    :location,
    :twitter_url,
    :events,
    to: :user

  def initialize(user, current_user: nil)
    @user = user
    @current_user = current_user
  end

  def website
    SafeUrl.parse(@user.website)
  end

  def initials
    name_parts = name.to_s.split
    return "" if name_parts.empty?
    return name_parts.first[0].upcase if name_parts.size == 1

    "#{name_parts.first[0]}#{name_parts.last[0]}".upcase
  end

  def avatar_color_class
    AVATAR_BG_CLASSES[username.bytes.sum % AVATAR_BG_CLASSES.size]
  end

  def shared_hobbies
    @shared_hobbies ||= hobbies.select { |hobby| current_user_hobby_ids.include?(hobby.id) }.sort_by(&:name)
  end

  def other_hobbies
    @other_hobbies ||= hobbies.reject { |hobby| current_user_hobby_ids.include?(hobby.id) }.sort_by(&:name)
  end

  def not_past_events
    events.not_past
  end

  def past_events
    events.past
  end

  private

  def current_user_hobby_ids
    @current_user_hobby_ids ||= @current_user&.hobby_ids&.to_set || Set.new
  end
end
