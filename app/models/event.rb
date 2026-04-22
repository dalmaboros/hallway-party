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
  validates :time_zone,
    inclusion: { in: ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name } }
  validate :ends_after_starts

  scope :active, -> { where("ends_at > ?", Time.current) }

  class << self
    def featured
      active.order(:starts_at).first
    end
  end

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be after starts_at")
  end
end
