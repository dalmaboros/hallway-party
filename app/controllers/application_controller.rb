# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :user_signed_in?
  before_action :require_sign_in!
  before_action :require_event_attendance!
  before_action :require_hobbies!

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = session[:user_id] && User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def require_sign_in!
    return if user_signed_in?

    redirect_to root_path, alert: "Please sign in to continue."
  end

  def require_event_attendance!
    return unless user_signed_in?
    return if current_user.events.exists?

    redirect_to onboarding_path
  end

  def require_hobbies!
    return unless user_signed_in?
    return if current_user.user_hobbies.exists?

    redirect_to onboarding_hobbies_path
  end
end
