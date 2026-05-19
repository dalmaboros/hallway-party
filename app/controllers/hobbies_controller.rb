# frozen_string_literal: true

class HobbiesController < ApplicationController
  def show
    @hobby_presenter = HobbyPresenter.new(hobby)
    @event_presenter = EventPresenter.new(event)
    @attendee_presenters = attendees_with_hobby.map { |attendee| UserPresenter.new(attendee) }
  end

  private

  def hobby
    @hobby ||= Hobby.find(params[:id])
  end

  def event
    @event ||= current_user.events.not_past.first
  end

  def attendees_with_hobby
    @attendees_with_hobby ||= event.users
      .joins(:user_hobbies)
      .where(user_hobbies: { hobby_id: hobby.id })
      .where.not(id: current_user.id)
      .includes(:hobbies)
      .order(:name)
  end
end
