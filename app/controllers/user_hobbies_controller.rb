# frozen_string_literal: true

class UserHobbiesController < ApplicationController
  skip_before_action :require_hobbies!

  def create
    name = params[:name].to_s.strip

    if name.blank?
      redirect_to onboarding_hobbies_path, alert: "Please enter a hobby." and return
    end

    hobby = Hobby.find_or_initialize_by(name: name)

    unless hobby.save
      redirect_to onboarding_hobbies_path, alert: hobby.errors.full_messages.to_sentence and return
    end

    current_user.user_hobbies.find_or_create_by!(hobby: hobby)
    GenerateHobbyEmbeddingJob.perform_later(hobby) if hobby.previously_new_record?

    redirect_to onboarding_hobbies_path, notice: "Added \"#{hobby.name}\"."
  end

  def destroy
    user_hobby = current_user.user_hobbies.find(params[:id])

    if user_hobby.destroy
      redirect_to onboarding_hobbies_path, notice: "Removed \"#{user_hobby.hobby.name}\"."
    else
      redirect_to onboarding_hobbies_path, alert: user_hobby.errors.full_messages.to_sentence
    end
  end
end
