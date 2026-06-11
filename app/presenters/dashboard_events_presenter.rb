# frozen_string_literal: true

class DashboardEventsPresenter
  def initialize(user)
    @user = user
  end

  def attendance_status
    if next_event.nil?
      most_recent_past_event ? :soft_sunset : :no_events
    elsif next_event.happening_today?
      next_event.attended_by?(@user) ? :happening_today : :happening_today_not_attending
    elsif next_event.attended_by?(@user)
      :upcoming_attending
    else
      :upcoming_not_attending
    end
  end

  def next_event
    @next_event ||= event_presenter(Event.not_past.first)
  end

  def most_recent_past_event
    @most_recent_past_event ||= event_presenter(@user.most_recent_past_event)
  end

  def upcoming_events
    @upcoming_events ||= @user.upcoming_events.map { |event| EventPresenter.new(event) }
  end

  private

  def event_presenter(event)
    EventPresenter.new(event) if event
  end
end
