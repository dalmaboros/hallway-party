# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: [:show]
  before_action :set_event_presenter, only: [:show]
  before_action :set_event_presenters, only: [:index]

  def index
    @attended_event_ids = current_user.event_ids.to_set
  end

  def show
    @viewer_is_attending = current_user.events.exists?(id: @event.id)
    return unless @viewer_is_attending

    @attendee_presenters = attendees.map { |attendee| UserPresenter.new(attendee) }
    @current_user_hobby_ids = current_user.hobby_ids.to_set
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_event_presenter
    @event_presenter = EventPresenter.new(@event)
  end

  def set_event_presenters
    @event_presenters = events.map { |event| EventPresenter.new(event) }
  end

  def events
    Event.active.order(:starts_at)
  end

  def attendees
    AttendeeMatcher.new(
      seed_hobbies: current_user.hobbies.to_a,
      event: @event,
      exclude_user: current_user,
    ).call
  end
end
