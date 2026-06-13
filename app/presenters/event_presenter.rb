# frozen_string_literal: true

class EventPresenter
  attr_reader :event

  delegate :name,
    :location,
    :start_date,
    :end_date,
    :current_date,
    :happening_today?,
    :current_day,
    :days_until_start,
    :upcoming?,
    :past?,
    :attendable?,
    :total_days,
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

  def short_date_range
    if start_date == end_date
      start_date.strftime("%b %-d, %Y")
    elsif start_date.year == end_date.year && start_date.month == end_date.month
      "#{start_date.strftime("%b %-d")}–#{end_date.day}, #{end_date.year}"
    else
      "#{start_date.strftime("%b %-d, %Y")} – #{end_date.strftime("%b %-d, %Y")}"
    end
  end

  def attended_by?(user)
    user.attendee_of?(event)
  end

  def attendance_statement
    past? ? "You attended" : "You're attending"
  end

  def attend_label
    past? ? "I attended" : "I am attending!"
  end
end
