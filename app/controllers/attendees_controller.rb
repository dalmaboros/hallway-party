# frozen_string_literal: true

class AttendeesController < ApplicationController
  before_action :set_event_presenter
  before_action :set_attendee_presenters, only: [:index]

  def index
  end

  private

  def set_event_presenter
    @event_presenter = EventPresenter.new(event)
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You're not attending that event."
  end

  def set_attendee_presenters
    @attendee_presenters = attendees.map { |attendee| UserPresenter.new(attendee) }
  end

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
