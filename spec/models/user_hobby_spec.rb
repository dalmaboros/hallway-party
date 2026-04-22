# frozen_string_literal: true

# == Schema Information
#
# Table name: user_hobbies
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hobby_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_hobbies_on_hobby_id              (hobby_id)
#  index_user_hobbies_on_hobby_id_and_user_id  (hobby_id,user_id) UNIQUE
#  index_user_hobbies_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (hobby_id => hobbies.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe UserHobby do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:hobby) }
  end

  describe "uniqueness" do
    subject { create(:user_hobby) }

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:hobby_id) }
  end

  describe "before_destroy: ensure_user_retains_at_least_one_hobby" do
    let(:user) { create(:user) }

    context "when the user has multiple hobbies" do
      before { create_list(:user_hobby, 2, user: user) }

      it "allows destroying one" do
        user_hobby = user.user_hobbies.first
        expect { user_hobby.destroy }.to change(described_class, :count).by(-1)
      end
    end

    context "when the user has only one hobby" do
      let!(:only_hobby) { create(:user_hobby, user: user) }

      it "prevents destruction" do
        expect { only_hobby.destroy }.not_to change(described_class, :count)
      end

      it "adds an error" do
        only_hobby.destroy
        expect(only_hobby.errors[:base]).to include("You must have at least one hobby")
      end
    end
  end
end
