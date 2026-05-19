# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show
    @user_presenter = UserPresenter.new(user, current_user:)
  end

  private

  def user
    @user ||= User.includes(:hobbies, :events).find_by!(username: params[:username])
  end
end
