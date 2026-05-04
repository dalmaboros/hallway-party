# frozen_string_literal: true

class HobbiesController < ApplicationController
  before_action :set_hobby, only: [:show]
  before_action :set_event, only: [:show]
  before_action :set_attendee_presenters, only: [:show]

  def show
    @current_user_hobby_ids = current_user.hobby_ids.to_set
  end

  private

  def set_hobby
    @hobby = Hobby.find(params[:id])
  end

  def set_event
    @event = current_user.events.active.first
  end

  def set_attendee_presenters
    @attendee_presenters = attendees.map { |attendee| UserPresenter.new(attendee) }
  end

  def attendees
    @event.users
      .joins(:user_hobbies)
      .where(user_hobbies: { hobby_id: @hobby.id })
      .where.not(id: current_user.id)
      .includes(:hobbies)
      .order(:name)
  end
end
