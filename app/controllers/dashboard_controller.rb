# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @user_presenter = UserPresenter.new(current_user)
    @hobby_presenters = current_user.hobbies.order(:name).map { |h| HobbyPresenter.new(h) }
    @event_presenter = EventPresenter.new(current_user.next_event) if current_user.next_event
  end
end
