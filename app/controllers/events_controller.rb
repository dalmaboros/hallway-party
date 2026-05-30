# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @event_presenters = not_past_events.map { |event| EventPresenter.new(event) }
  end

  def show
    @event_presenter = EventPresenter.new(event)
    return unless @event_presenter.attended_by?(current_user)

    @matched_user_presenters = matched_attendees.map { |attendee| UserPresenter.new(attendee) }
    @other_user_presenters = other_attendees.map { |attendee| UserPresenter.new(attendee) }
  end

  private

  def event
    @event ||= Event.find(params[:id])
  end

  def not_past_events
    @not_past_events ||= Event.not_past
  end

  def matched_attendees
    @matched_attendees ||= AttendeeMatcher.new(user: current_user, event:).match_attendees
  end

  def other_attendees
    event.users
      .where.not(id: [current_user.id, *matched_attendees.map(&:id)])
      .includes(:hobbies)
      .order(:name)
  end
end
