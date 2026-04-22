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
require "rails_helper"

RSpec.describe Event do
  describe "validations" do
    subject(:event) { build(:event) }

    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:website) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:time_zone) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }

    it "rejects ends_at before starts_at" do
      event.starts_at = Time.current
      event.ends_at = 1.hour.ago
      expect(event).not_to be_valid
    end

    it "rejects ends_at equal to starts_at" do
      now = Time.current
      event.starts_at = now
      event.ends_at = now
      expect(event).not_to be_valid
    end

    it "rejects an invalid IANA time zone" do
      event = build(:event, time_zone: "Not/A/Zone")
      expect(event).not_to be_valid
    end

    it "accepts a valid IANA time zone" do
      event = build(:event, time_zone: "America/New_York")
      expect(event).to be_valid
    end
  end

  describe ".featured" do
    context "when no events exist" do
      it "returns nil" do
        expect(described_class.featured).to be_nil
      end
    end

    context "when multiple events exist" do
      let(:soon) { 1.week.from_now }
      let(:later) { soon + 3.weeks }

      before do
        create(:event, :past)
        create(:event, starts_at: later, ends_at: later + 2.days)
      end

      it "returns the soonest upcoming event" do
        soon_event = create(:event, starts_at: soon, ends_at: soon + 2.days)

        expect(described_class.featured).to eq(soon_event)
      end
    end

    it "returns an in-progress event (not yet ended)" do
      current = create(:event, :in_progress)
      expect(described_class.featured).to eq(current)
    end

    it "returns nil when only past events exist" do
      create(:event, :past)
      expect(described_class.featured).to be_nil
    end
  end
end
