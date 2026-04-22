# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                          :bigint           not null, primary key
#  avatar_url                  :string
#  bio                         :text
#  bluesky_url                 :string
#  email                       :string
#  email_notifications_enabled :boolean          default(TRUE), not null
#  linkedin_url                :string
#  location                    :string
#  mastodon_url                :string
#  name                        :string           not null
#  pronouns                    :string
#  provider                    :string           not null
#  twitter_url                 :string
#  uid                         :string           not null
#  username                    :string           not null
#  website                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_users_on_email             (email) UNIQUE
#  index_users_on_provider_and_uid  (provider,uid) UNIQUE
#  index_users_on_username          (username) UNIQUE
#
require "rails_helper"

RSpec.describe User do
  describe "validations" do
    subject(:user) { build(:user) }

    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to allow_value("valid@example.com").for(:email) }
    it { is_expected.to allow_value(nil).for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }

    describe "uniqueness" do
      subject { create(:user) }

      it { is_expected.to validate_uniqueness_of(:username) }
      it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive.allow_nil }
    end
  end

  describe "email normalization" do
    it "downcases email before save" do
      user = create(:user, email: "MixedCase@Example.Com")
      expect(user.email).to eq("mixedcase@example.com")
    end
  end
end
