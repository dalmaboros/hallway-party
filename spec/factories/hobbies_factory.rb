# frozen_string_literal: true

# == Schema Information
#
# Table name: hobbies
#
#  id         :bigint           not null, primary key
#  embedding  :vector(1536)
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_hobbies_on_embedding  (embedding) USING hnsw
#  index_hobbies_on_name       (name) UNIQUE
#
FactoryBot.define do
  factory :hobby do
    sequence(:name) { |n| "Hobby #{n}" }
    # embedding is nil — populated async by the embedding job in real use;
    # tests can set it explicitly when needed
  end
end
