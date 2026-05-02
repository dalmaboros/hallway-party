# frozen_string_literal: true

module EventsHelper
  def event_date_range(event)
    start_date = event.starts_at.in_time_zone(event.time_zone).to_date
    end_date = event.ends_at.in_time_zone(event.time_zone).to_date

    if start_date == end_date
      start_date.strftime("%B %-d, %Y")
    elsif start_date.year == end_date.year && start_date.month == end_date.month
      "#{start_date.strftime("%B %-d")}–#{end_date.day}, #{end_date.year}"
    else
      "#{start_date.strftime("%B %-d, %Y")} – #{end_date.strftime("%B %-d, %Y")}"
    end
  end
end
