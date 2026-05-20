# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @user_presenter = UserPresenter.new(current_user)
    @hobby_presenters = current_user.hobbies.order(:name).map { |h| HobbyPresenter.new(h) }
    @upcoming_event_presenters = current_user.events.not_past.map { |e| EventPresenter.new(e) }
    @next_event_presenter = @upcoming_event_presenters.first
  end
end
