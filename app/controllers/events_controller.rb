# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @events = Event.active.order(:starts_at)
    @attended_event_ids = current_user.event_ids.to_set
  end

  def show
    @event = Event.find(params[:id])
    @viewer_is_attending = current_user.events.exists?(id: @event.id)
    return unless @viewer_is_attending

    @attendees = AttendeeMatcher.new(
      seed_hobbies: current_user.hobbies.to_a,
      event: @event,
      exclude_user: current_user,
    ).call
    @current_user_hobby_ids = current_user.hobby_ids.to_set
  end
end
