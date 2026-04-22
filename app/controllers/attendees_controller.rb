# frozen_string_literal: true

class AttendeesController < ApplicationController
  before_action :set_event

  def index
    @attendees = AttendeeMatcher.call(
      seed_hobbies: current_user.hobbies.to_a,
      event: @event,
      exclude_user: current_user,
    )
  end

  private

  def set_event
    @event = current_user.events.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You're not attending that event."
  end
end
