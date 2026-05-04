# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :set_user_presenter, only: [:show]

  def show
    @current_user_hobby_ids = current_user.hobby_ids.to_set
  end

  private

  def set_user
    @user = User.includes(:hobbies, :events).find_by!(username: params[:username])
  end

  def set_user_presenter
    @user_presenter = UserPresenter.new(@user)
  end
end
