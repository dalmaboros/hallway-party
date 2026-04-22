# frozen_string_literal: true

# == Schema Information
#
# Table name: event_attendances
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_event_attendances_on_event_id              (event_id)
#  index_event_attendances_on_user_id               (user_id)
#  index_event_attendances_on_user_id_and_event_id  (user_id,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#  fk_rails_...  (user_id => users.id)
#
class EventAttendance < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :user_id, uniqueness: { scope: :event_id }
  validate :no_overlapping_attendance

  private

  def no_overlapping_attendance
    return unless user && event

    overlap = user.event_attendances
      .where.not(id: id)
      .joins(:event)
      .exists?(["events.starts_at < ? AND events.ends_at > ?", event.ends_at, event.starts_at])

    return unless overlap

    errors.add(:base, "You're already attending another event that overlaps with these dates")
  end
end
