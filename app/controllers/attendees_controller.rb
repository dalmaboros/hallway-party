# frozen_string_literal: true

class AttendeesController < ApplicationController
  before_action :set_event

  def index
    @attendees = AttendeeMatcher.new(
      seed_hobbies: current_user.hobbies.to_a,
      event: @event,
      exclude_user: current_user,
    ).call
    @current_user_hobby_ids = current_user.hobby_ids.to_set
  end

  private

  def set_event
    @event = current_user.events.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You're not attending that event."
  end
end
