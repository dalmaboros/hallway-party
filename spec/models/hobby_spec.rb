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
require "rails_helper"

RSpec.describe Hobby do
  describe "associations" do
    it { is_expected.to have_many(:user_hobbies).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_hobbies) }
  end

  describe "validations" do
    subject { create(:hobby) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe "citext name" do
    it "treats case differences as the same hobby" do
      create(:hobby, name: "Knitting")
      duplicate = build(:hobby, name: "KNITTING")
      expect(duplicate).not_to be_valid
    end
  end
end
