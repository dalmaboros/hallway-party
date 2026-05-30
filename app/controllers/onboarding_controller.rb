# frozen_string_literal: true

class OnboardingController < ApplicationController
  skip_before_action :require_event_attendance!, only: [:welcome, :submit_attendance, :declined]
  skip_before_action :require_hobbies!

  def welcome
    @featured_event_presenter = EventPresenter.new(featured_event) if featured_event
    render :no_events if @featured_event_presenter.nil?
  end

  def submit_attendance
    return redirect_to onboarding_path if featured_event.nil?

    case params[:answer]
    when "yes"
      EventAttendance.create!(user: current_user, event: featured_event)
      redirect_to onboarding_hobbies_path, notice: "You're attending #{featured_event.name}! Now add a few hobbies."
    when "no"
      redirect_to onboarding_declined_path
    else
      redirect_to onboarding_path, alert: "Please choose yes or no."
    end
  end

  def manage_hobbies
    @user_hobby_presenters = current_user.user_hobbies
      .includes(:hobby)
      .order("hobbies.name")
      .map { |user_hobby| UserHobbyPresenter.new(user_hobby) }
    @event_presenter = EventPresenter.new(attending_event) if attending_event
  end

  def declined
  end

  private

  def featured_event
    @featured_event ||= Event.featured
  end

  def attending_event
    @attending_event ||= current_user.events.not_past.first
  end
end
