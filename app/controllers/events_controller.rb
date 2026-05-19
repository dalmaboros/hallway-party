# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @event_presenters = events.map { |e| EventPresenter.new(e) }
  end

  def show
    @event_presenter = EventPresenter.new(event)
    return unless @event_presenter.attended_by?(current_user)

    @attendee_presenters = attendees.map { |attendee| UserPresenter.new(attendee) }
  end

  private

  def event
    @event ||= Event.find(params[:id])
  end

  def events
    @events ||= Event.not_past
  end

  def attendees
    @attendees ||= AttendeeMatcher.new(
      seed_hobbies: current_user.hobbies.to_a,
      event: event,
      exclude_user: current_user,
    ).call
  end
end
