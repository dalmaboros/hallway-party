# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @user_presenter = UserPresenter.new(current_user)
    @hobby_presenters = current_user.hobbies.order(:name).map { |h| HobbyPresenter.new(h) }
    @dashboard_events_presenter = DashboardEventsPresenter.new(current_user)
  end
end
