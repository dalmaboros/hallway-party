# frozen_string_literal: true

module Dev
  class SessionsController < ApplicationController
    skip_before_action :require_sign_in!
    skip_before_action :require_event_attendance!
    skip_before_action :require_hobbies!
    before_action :ensure_development_only

    def index
      @users = User.where(provider: "seed").order(:username)
    end

    def create
      user = User.find_by!(provider: "seed", username: params[:username])
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Signed in as @#{user.username}"
    end

    private

    def ensure_development_only
      head :not_found unless Rails.env.development?
    end
  end
end
