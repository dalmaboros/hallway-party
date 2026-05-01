# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show
    @user = User.includes(:hobbies, :events).find_by!(username: params[:username])
    @current_user_hobby_ids = current_user.hobby_ids.to_set
  end
end
