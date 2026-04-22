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
  describe "associations" do
    it { is_expected.to have_many(:event_attendances).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:event_attendances) }
  end

  describe "validations" do
    subject(:event) { build(:event) }

    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:website) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:time_zone) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }

    it { is_expected.to allow_value("America/New_York").for(:time_zone) }
    it { is_expected.not_to allow_value("Not/A/Zone").for(:time_zone) }

    context "when ends_at is before starts_at" do
      before do
        event.starts_at = Time.current
        event.ends_at = 1.hour.ago
      end

      it "is invalid" do
        expect(event).not_to be_valid
      end
    end

    context "when ends_at equals starts_at" do
      let(:now) { Time.current }

      before do
        event.starts_at = now
        event.ends_at = now
      end

      it "is invalid" do
        expect(event).not_to be_valid
      end
    end
  end

  describe ".active" do
    context "when the event is upcoming" do
      let!(:event) { create(:event, :upcoming) }

      it "is included" do
        expect(described_class.active).to include(event)
      end
    end

    context "when the event is in progress" do
      let!(:event) { create(:event, :in_progress) }

      it "is included" do
        expect(described_class.active).to include(event)
      end
    end

    context "when the event has ended" do
      let!(:event) { create(:event, :past) }

      it "is excluded" do
        expect(described_class.active).not_to include(event)
      end
    end
  end

  describe ".featured" do
    context "when no events exist" do
      it "returns nil" do
        expect(described_class.featured).to be_nil
      end
    end

    context "when only past events exist" do
      before { create(:event, :past) }

      it "returns nil" do
        expect(described_class.featured).to be_nil
      end
    end

    context "when an in-progress event exists" do
      let!(:current) { create(:event, :in_progress) }

      it "returns the in-progress event" do
        expect(described_class.featured).to eq(current)
      end
    end

    context "when multiple upcoming events exist" do
      let!(:soon) do
        create(
          :event,
          starts_at: 1.week.from_now,
          ends_at: 1.week.from_now + 2.days,
        )
      end

      before do
        create(:event, :past)
        create(
          :event,
          starts_at: 3.months.from_now,
          ends_at: 3.months.from_now + 2.days,
        )
      end

      it "returns the soonest upcoming event" do
        expect(described_class.featured).to eq(soon)
      end
    end
  end
end
