# frozen_string_literal: true

class AttendeesController < ApplicationController
  def index
    @event_presenter = EventPresenter.new(event)
    @attendee_presenters = attendees.map { |attendee| UserPresenter.new(attendee) }
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You're not attending that event."
  end

  private

  def event
    @event ||= current_user.events.find(params[:event_id])
  end

  def attendees
    @attendees ||= AttendeeMatcher.new(
      seed_hobbies: current_user.hobbies.to_a,
      event: event,
      exclude_user: current_user,
    ).call
  end
end
