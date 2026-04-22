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
class Hobby < ApplicationRecord
  has_neighbors :embedding, dimensions: 1536

  has_many :user_hobbies, dependent: :destroy
  has_many :users, through: :user_hobbies

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
