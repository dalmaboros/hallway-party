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
FactoryBot.define do
  factory :event_attendance do
    user
    event
  end
end
