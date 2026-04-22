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
FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "RubyConf 20#{25 + n}" }
    website { "https://example.com/rubyconf" }
    location { "Las Vegas, NV" }
    time_zone { "America/Los_Angeles" }
    starts_at { 1.month.from_now }
    ends_at { 1.month.from_now + 3.days }

    trait :past do
      starts_at { 6.months.ago }
      ends_at { 6.months.ago + 3.days }
    end

    trait :in_progress do
      starts_at { 1.day.ago }
      ends_at { 2.days.from_now }
    end

    trait :upcoming do
      starts_at { 1.month.from_now }
      ends_at { 1.month.from_now + 3.days }
    end
  end
end
