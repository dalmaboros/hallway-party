# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @event_presenters = not_past_events.map { |event| EventPresenter.new(event) }
  end

  def show
    @event_presenter = EventPresenter.new(event)
    return unless @event_presenter.attended_by?(current_user)

    @user_presenters = attendees_matched_by_hobby.map { |attendee| UserPresenter.new(attendee) }
  end

  private

  def event
    @event ||= Event.find(params[:id])
  end

  def not_past_events
    @not_past_events ||= Event.not_past
  end

  def attendees_matched_by_hobby
    @attendees_matched_by_hobby ||= AttendeeMatcher.new(user: current_user, event:).match_attendees
  end
end
