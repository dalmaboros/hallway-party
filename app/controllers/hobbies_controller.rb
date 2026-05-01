# frozen_string_literal: true

class HobbiesController < ApplicationController
  def show
    @hobby = Hobby.find(params[:id])
    @event = current_user.events.active.first
    @attendees = @event.users
      .joins(:user_hobbies)
      .where(user_hobbies: { hobby_id: @hobby.id })
      .where.not(id: current_user.id)
      .includes(:hobbies)
      .order(:name)
    @current_user_hobby_ids = current_user.hobby_ids.to_set
  end
end
