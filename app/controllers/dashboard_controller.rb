# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @user_presenter = UserPresenter.new(current_user)
    @hobby_presenters = current_user.hobbies.order(:name).map { |h| HobbyPresenter.new(h) }
    @event_presenter = EventPresenter.new(next_event) if next_event
  end

  private

  def next_event
    @next_event ||= current_user.events.not_past.first
  end
end
