# frozen_string_literal: true

class DashboardEventsPresenter
  def initialize(user)
    @user = user
  end

  def banner_state
    if next_event.nil?
      most_recent_past_event ? :soft_sunset : :no_events
    elsif next_event.happening_today?
      :happening_today
    else
      :upcoming
    end
  end

  def next_event
    @next_event ||= wrap(@user.next_event)
  end

  def most_recent_past_event
    @most_recent_past_event ||= wrap(@user.most_recent_past_event)
  end

  def upcoming_events
    @upcoming_events ||= @user.upcoming_events.map { |event| EventPresenter.new(event) }
  end

  private

  def wrap(event)
    EventPresenter.new(event) if event
  end
end
