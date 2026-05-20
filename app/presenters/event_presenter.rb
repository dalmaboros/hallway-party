# frozen_string_literal: true

class EventPresenter
  attr_reader :event

  delegate :to_param,
    :name,
    :location,
    :start_date,
    :end_date,
    :current_date,
    :happening_today?,
    to: :event

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

  def current_day
    return unless happening_today?

    (current_date - start_date).to_i + 1
  end

  def total_days
    (end_date - start_date).to_i + 1
  end

  def attended_by?(user)
    user.attendee_of?(event)
  end
end
