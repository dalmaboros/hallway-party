# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event_presenter, only: [:show]
  before_action :set_event_presenters, only: [:index]

  def index
  end

  def show
    return unless current_user.attendee_of?(event)

    @attendee_presenters = attendees.map { |attendee| UserPresenter.new(attendee) }
  end

  private

  def set_event_presenter
    @event_presenter = EventPresenter.new(event)
  end

  def set_event_presenters
    @event_presenters = events.map { |e| EventPresenter.new(e) }
  end

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
