# frozen_string_literal: true

class UserHobbyPresenter
  attr_reader :user_hobby

  delegate :to_param, to: :user_hobby

  def initialize(user_hobby)
    @user_hobby = user_hobby
  end

  def hobby_name
    user_hobby.hobby.name&.downcase
  end
end
