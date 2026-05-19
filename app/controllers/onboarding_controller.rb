# frozen_string_literal: true

class OnboardingController < ApplicationController
  skip_before_action :require_event_attendance!, only: [:show, :create, :declined]
  skip_before_action :require_hobbies!

  before_action :featured_event, only: [:show, :create]

  def show
    @featured_event_presenter = EventPresenter.new(@featured_event) if @featured_event
    render :no_events if @featured_event_presenter.nil?
  end

  def create
    return redirect_to onboarding_path if @featured_event.nil?

    case params[:answer]
    when "yes"
      EventAttendance.create!(user: current_user, event: @featured_event)
      redirect_to onboarding_hobbies_path, notice: "You're attending #{@featured_event.name}! Now add a few hobbies."
    when "no"
      redirect_to onboarding_declined_path
    else
      redirect_to onboarding_path, alert: "Please choose yes or no."
    end
  end

  def hobbies
  end

  def declined
  end

  private

  def featured_event
    @featured_event = Event.featured
  end
end
