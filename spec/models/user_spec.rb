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
  describe "associations" do
    it { is_expected.to have_many(:event_attendances).dependent(:destroy) }
    it { is_expected.to have_many(:events).through(:event_attendances) }
    it { is_expected.to have_many(:user_hobbies).dependent(:destroy) }
    it { is_expected.to have_many(:hobbies).through(:user_hobbies) }
  end

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

  describe "#github_url" do
    let(:user) { build(:user, username: "dalmaboros") }

    it "returns the user's GitHub profile URL" do
      expect(user.github_url).to eq("https://github.com/dalmaboros")
    end
  end

  describe "#has_hobby?" do
    let(:user) { create(:user) }
    let(:knitting) { create(:hobby, name: "knitting") }
    let(:cycling) { create(:hobby, name: "cycling") }

    context "when the user has the hobby" do
      before { user.hobbies << knitting }

      it "returns true" do
        expect(user.has_hobby?(knitting)).to be(true)
      end
    end

    context "when the user does not have the hobby" do
      before { user.hobbies << knitting }

      it "returns false" do
        expect(user.has_hobby?(cycling)).to be(false)
      end
    end

    context "when the user has no hobbies" do
      it "returns false" do
        expect(user.has_hobby?(knitting)).to be(false)
      end
    end
  end

  describe "#attendee_of?" do
    let(:user) { create(:user) }
    let(:rubyconf) { create(:event) }
    let(:railsconf) { create(:event) }

    context "when the user attends the event" do
      before { user.events << rubyconf }

      it "returns true" do
        expect(user.attendee_of?(rubyconf)).to be(true)
      end
    end

    context "when the user does not attend the event" do
      before { user.events << railsconf }

      it "returns false" do
        expect(user.attendee_of?(rubyconf)).to be(false)
      end
    end

    context "when the user attends no events" do
      it "returns false" do
        expect(user.attendee_of?(rubyconf)).to be(false)
      end
    end
  end

  describe "event derivations" do
    let(:user) { create(:user) }
    let(:soon) { create(:event, starts_at: 1.week.from_now, ends_at: 1.week.from_now + 2.days) }
    let(:later) { create(:event, starts_at: 2.months.from_now, ends_at: 2.months.from_now + 2.days) }
    let(:older_past) { create(:event, starts_at: 6.months.ago, ends_at: 6.months.ago + 2.days) }
    let(:recent_past) { create(:event, starts_at: 1.month.ago, ends_at: 1.month.ago + 2.days) }

    describe "#upcoming_events" do
      it "returns only the not-past events, soonest first" do
        user.events << [later, recent_past, soon, older_past]
        expect(user.upcoming_events).to eq([soon, later])
      end

      it "is empty when the user has only past events" do
        user.events << [older_past, recent_past]
        expect(user.upcoming_events).to be_empty
      end
    end

    describe "#next_event" do
      it "returns the soonest upcoming event" do
        user.events << [later, soon]
        expect(user.next_event).to eq(soon)
      end

      it "returns nil when the user has no upcoming events" do
        user.events << recent_past
        expect(user.next_event).to be_nil
      end
    end

    describe "#most_recent_past_event" do
      it "returns the most recently ended past event" do
        user.events << [older_past, recent_past]
        expect(user.most_recent_past_event).to eq(recent_past)
      end

      it "returns nil when the user has no past events" do
        user.events << soon
        expect(user.most_recent_past_event).to be_nil
      end
    end
  end
end
