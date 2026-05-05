# frozen_string_literal: true

class OnboardingController < ApplicationController
  skip_before_action :require_event_attendance!, only: [:show, :create]
  skip_before_action :require_hobbies!

  before_action :set_featured_event_presenter, only: [:show]

  def show
    render :no_events if @featured_event_presenter.nil?
  end

  def create
    featured_event = Event.featured

    if featured_event.nil?
      redirect_to onboarding_path and return
    end

    case params[:answer]
    when "yes"
      EventAttendance.create!(user: current_user, event: featured_event)
      redirect_to onboarding_hobbies_path, notice: "You're attending #{featured_event.name}! Now add a few hobbies."
    when "no"
      reset_session
      redirect_to root_path, notice: "No problem — Hallway Party is event-specific. Come back when you're attending one."
    else
      redirect_to onboarding_path, alert: "Please choose yes or no."
    end
  end

  def hobbies; end

  private

  def set_featured_event_presenter
    event = Event.featured
    @featured_event_presenter = EventPresenter.new(event) if event
  end
end
