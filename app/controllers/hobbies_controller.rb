# frozen_string_literal: true

class HobbiesController < ApplicationController
  def show
    @hobby_presenter = HobbyPresenter.new(hobby)
    @user_presenters = hobbyists.map { |hobbyist| UserPresenter.new(hobbyist) }
    @current_user_hobby = current_user.user_hobbies.find_by(hobby: hobby)
    @membership_removable = @current_user_hobby.present? && current_user.user_hobbies.many?
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
