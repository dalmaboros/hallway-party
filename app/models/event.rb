# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id         :bigint           not null, primary key
#  ends_at    :datetime         not null
#  location   :string           not null
#  name       :string           not null
#  starts_at  :datetime         not null
#  time_zone  :string           not null
#  website    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_events_on_starts_at  (starts_at)
#
class Event < ApplicationRecord
  has_many :event_attendances, dependent: :destroy
  has_many :users, through: :event_attendances

  validates :name, :website, :location, :time_zone, :starts_at, :ends_at, presence: true
  validates :website, format: { with: %r{\Ahttps?://\S+\z}i, message: "must start with http:// or https://" }, allow_blank: true
  validates :time_zone,
    inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }
  validate :ends_after_starts

  scope :not_past, -> { where("ends_at > ?", Time.current).order(:starts_at) }
  scope :upcoming, -> { where("starts_at > ?", Time.current).order(:starts_at) }
  scope :in_progress, -> { where("starts_at <= ? AND ends_at > ?", Time.current, Time.current).order(:starts_at) }
  scope :past, -> { where(ends_at: ...Time.current).order(starts_at: :desc) }

  class << self
    def featured
      not_past.first
    end
  end

  def happening_today?
    current_date.between?(start_date, end_date)
  end

  def start_date
    starts_at.in_time_zone(time_zone).to_date
  end

  def end_date
    ends_at.in_time_zone(time_zone).to_date
  end

  def current_date
    Time.current.in_time_zone(time_zone).to_date
  end

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after starts_at")
  end
end
