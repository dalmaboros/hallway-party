# frozen_string_literal: true

class UserHobbiesController < ApplicationController
  skip_before_action :require_hobbies!

  def create
    return add_existing_hobby if params[:hobby_id]

    name = params[:name].to_s.strip
    return redirect_to onboarding_hobbies_path, alert: "Please enter a hobby." if name.blank?

    hobby = Hobby.find_or_initialize_by(name: name)
    return redirect_to onboarding_hobbies_path, alert: hobby.errors.full_messages.to_sentence unless hobby.save

    current_user.user_hobbies.find_or_create_by!(hobby: hobby)
    GenerateHobbyEmbeddingJob.perform_later(hobby) if hobby.previously_new_record?

    redirect_to onboarding_hobbies_path, notice: "Added \"#{HobbyPresenter.new(hobby).name}\"."
  end

  def destroy
    user_hobby = current_user.user_hobbies.find(params[:id])

    if current_user.user_hobbies.one?
      return redirect_back_or_to onboarding_hobbies_path, alert: "You must have at least one hobby"
    end

    user_hobby.destroy!

    notice = "Removed \"#{HobbyPresenter.new(user_hobby.hobby).name}\"." unless turbo_frame_request?
    redirect_back_or_to onboarding_hobbies_path, notice: notice
  end

  private

  def add_existing_hobby
    hobby = Hobby.find(params[:hobby_id])
    current_user.user_hobbies.find_or_create_by!(hobby: hobby)
    redirect_to hobby_path(hobby)
  end
end
