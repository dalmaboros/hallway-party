# frozen_string_literal: true

class AttendancesController < ApplicationController
  def create
    attendance = current_user.event_attendances.build(event:)

    if attendance.save
      redirect_back_or_to events_path, notice: "You're attending #{event.name}."
    else
      redirect_back_or_to events_path, alert: attendance.errors.full_messages.to_sentence
    end
  end

  def destroy
    attendance = current_user.event_attendances.find_by(event:)
    attendance&.destroy

    redirect_back_or_to events_path, notice: ("You're no longer attending #{event.name}." if attendance)
  end

  private

  def event
    @event ||= Event.find(params[:event_id])
  end
end
