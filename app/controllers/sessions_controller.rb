# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_sign_in!, only: [:create, :failure]

  def create
    auth_hash = request.env["omniauth.auth"]
    user = GithubUserSyncService.call(auth_hash)
    session[:user_id] = user.id
    redirect_to "/dashboard", notice: "Welcome, #{user.name}!"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out."
  end

  def failure
    redirect_to root_path, alert: "Sign-in failed: #{params[:message]}"
  end
end
