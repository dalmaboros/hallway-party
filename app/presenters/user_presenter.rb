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
    :bio,
    :pronouns,
    :location,
    :twitter_url,
    :github_url,
    :events,
    to: :user

  def initialize(user, current_user: nil)
    @user = user
    @current_user = current_user
  end

  def hobby_presenters
    @hobby_presenters ||= user_hobbies.sort_by(&:name).map do |hobby|
      HobbyPresenter.new(hobby)
    end
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

  def shared_hobby_presenters
    @shared_hobby_presenters ||= shared_hobbies.map do |hobby|
      HobbyPresenter.new(hobby)
    end
  end

  def non_shared_hobby_presenters
    @non_shared_hobby_presenters ||= non_shared_hobbies.map do |hobby|
      HobbyPresenter.new(hobby)
    end
  end

  def not_past_events
    events.not_past
  end

  def past_events
    events.past
  end

  private

  def user_hobbies
    @user_hobbies ||= user.hobbies.to_a
  end

  def current_user_hobbies
    @current_user_hobbies ||= @current_user&.hobbies.to_a
  end

  def shared_hobbies
    (user_hobbies & current_user_hobbies).sort_by(&:name)
  end

  def non_shared_hobbies
    (user_hobbies - current_user_hobbies).sort_by(&:name)
  end
end
