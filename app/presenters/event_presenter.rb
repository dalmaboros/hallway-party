# frozen_string_literal: true

class EventPresenter
  attr_reader :event

  delegate :id, :to_param, :name, :location, to: :event

  def initialize(event)
    @event = event
  end

  def website
    SafeUrl.parse(@event.website)
  end

  def date_range
    if start_date == end_date
      start_date.strftime("%B %-d, %Y")
    elsif start_date.year == end_date.year && start_date.month == end_date.month
      "#{start_date.strftime("%B %-d")}–#{end_date.day}, #{end_date.year}"
    else
      "#{start_date.strftime("%B %-d, %Y")} – #{end_date.strftime("%B %-d, %Y")}"
    end
  end

  def in_progress?
    current_date.between?(start_date, end_date)
  end

  def current_day
    return unless in_progress?

    (current_date - start_date).to_i + 1
  end

  def total_days
    (end_date - start_date).to_i + 1
  end

  private

  def start_date
    @start_date ||= @event.starts_at.in_time_zone(@event.time_zone).to_date
  end

  def end_date
    @end_date ||= @event.ends_at.in_time_zone(@event.time_zone).to_date
  end

  def current_date
    Time.current.in_time_zone(@event.time_zone).to_date
  end
end
