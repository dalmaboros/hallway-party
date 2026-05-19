# frozen_string_literal: true

class UserHobbiesController < ApplicationController
  skip_before_action :require_hobbies!

  def create
    name = params[:name].to_s.strip
    return redirect_to onboarding_hobbies_path, alert: "Please enter a hobby." if name.blank?

    hobby = Hobby.find_or_initialize_by(name: name)
    return redirect_to onboarding_hobbies_path, alert: hobby.errors.full_messages.to_sentence unless hobby.save

    current_user.user_hobbies.find_or_create_by!(hobby: hobby)
    GenerateHobbyEmbeddingJob.perform_later(hobby) if hobby.previously_new_record?

    redirect_to onboarding_hobbies_path, notice: "Added \"#{hobby.display_name}\"."
  end

  def destroy
    user_hobby = current_user.user_hobbies.find(params[:id])

    if current_user.user_hobbies.one?
      return redirect_to onboarding_hobbies_path, alert: "You must have at least one hobby"
    end

    user_hobby.destroy!
    redirect_to onboarding_hobbies_path, notice: "Removed \"#{user_hobby.hobby.display_name}\"."
  end
end
