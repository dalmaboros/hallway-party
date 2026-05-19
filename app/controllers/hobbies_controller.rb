# frozen_string_literal: true

class HobbiesController < ApplicationController
  def show
    @hobby_presenter = HobbyPresenter.new(hobby)
    @user_presenters = hobbyists.map { |hobbyist| UserPresenter.new(hobbyist) }
  end

  private

  def hobby
    @hobby ||= Hobby.find(params[:id])
  end

  def hobbyists
    @hobbyists ||= hobby.users
      .where.not(id: current_user.id)
      .includes(:hobbies)
      .order(:name)
  end
end
