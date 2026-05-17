# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :set_dashboard_presenters, only: [:index]

  def index
    @hobbies = current_user.hobbies.order(:name)
  end

  private

  def set_dashboard_presenters
    @user_presenter = UserPresenter.new(current_user)
    current_event = current_user.events.not_past.first
    @current_event_presenter = EventPresenter.new(current_event) if current_event
  end
end
