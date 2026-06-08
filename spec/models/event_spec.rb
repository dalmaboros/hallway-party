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

    it { is_expected.to allow_value("https://example.com").for(:website) }
    it { is_expected.to allow_value("http://example.com").for(:website) }
    it { is_expected.not_to allow_value("javascript:alert(1)").for(:website) }
    it { is_expected.not_to allow_value("ftp://example.com").for(:website) }

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

  describe ".not_past" do
    context "when the event is upcoming" do
      let!(:event) { create(:event, :upcoming) }

      it "is included" do
        expect(described_class.not_past).to include(event)
      end
    end

    context "when the event is in progress" do
      let!(:event) { create(:event, :in_progress) }

      it "is included" do
        expect(described_class.not_past).to include(event)
      end
    end

    context "when the event has ended" do
      let!(:event) { create(:event, :past) }

      it "is excluded" do
        expect(described_class.not_past).not_to include(event)
      end
    end

    context "when there are multiple not_past events" do
      let!(:sooner_event) { create(:event, starts_at: 1.week.from_now, ends_at: 1.week.from_now + 2.days) }
      let!(:later_event) { create(:event, starts_at: 3.months.from_now, ends_at: 3.months.from_now + 2.days) }

      it "orders by start date ascending" do
        expect(described_class.not_past).to eq([sooner_event, later_event])
      end
    end
  end

  describe ".upcoming" do
    context "when the event is upcoming" do
      let!(:event) { create(:event, :upcoming) }

      it "is included" do
        expect(described_class.upcoming).to include(event)
      end
    end

    context "when the event is in progress" do
      let!(:event) { create(:event, :in_progress) }

      it "is excluded" do
        expect(described_class.upcoming).not_to include(event)
      end
    end

    context "when the event has ended" do
      let!(:event) { create(:event, :past) }

      it "is excluded" do
        expect(described_class.upcoming).not_to include(event)
      end
    end

    context "when there are multiple upcoming events" do
      let!(:sooner_event) { create(:event, starts_at: 1.week.from_now, ends_at: 1.week.from_now + 2.days) }
      let!(:later_event) { create(:event, starts_at: 3.months.from_now, ends_at: 3.months.from_now + 2.days) }

      it "orders by start date ascending" do
        expect(described_class.upcoming).to eq([sooner_event, later_event])
      end
    end
  end

  describe ".in_progress" do
    context "when the event is upcoming" do
      let!(:event) { create(:event, :upcoming) }

      it "is excluded" do
        expect(described_class.in_progress).not_to include(event)
      end
    end

    context "when the event is in progress" do
      let!(:event) { create(:event, :in_progress) }

      it "is included" do
        expect(described_class.in_progress).to include(event)
      end
    end

    context "when the event has ended" do
      let!(:event) { create(:event, :past) }

      it "is excluded" do
        expect(described_class.in_progress).not_to include(event)
      end
    end

    context "when there are multiple in_progress events" do
      let!(:sooner_event) { create(:event, starts_at: 2.days.ago, ends_at: 1.day.from_now) }
      let!(:later_event) { create(:event, starts_at: 1.hour.ago, ends_at: 2.days.from_now) }

      it "orders by start date ascending" do
        expect(described_class.in_progress).to eq([sooner_event, later_event])
      end
    end
  end

  describe ".past" do
    context "when the event is upcoming" do
      let!(:event) { create(:event, :upcoming) }

      it "is excluded" do
        expect(described_class.past).not_to include(event)
      end
    end

    context "when the event is in progress" do
      let!(:event) { create(:event, :in_progress) }

      it "is excluded" do
        expect(described_class.past).not_to include(event)
      end
    end

    context "when the event has ended" do
      let!(:event) { create(:event, :past) }

      it "is included" do
        expect(described_class.past).to include(event)
      end
    end

    context "when there are multiple past events" do
      let!(:sooner_event) { create(:event, starts_at: 1.year.ago, ends_at: 1.year.ago + 2.days) }
      let!(:later_event) { create(:event, starts_at: 2.months.ago, ends_at: 2.months.ago + 2.days) }

      it "orders by start date descending — most-recent past first" do
        expect(described_class.past).to eq([later_event, sooner_event])
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

  describe "#start_date" do
    let(:event) do
      build(
        :event,
        time_zone: "Australia/Sydney",
        starts_at: Time.utc(2026, 7, 13, 23, 30),
        ends_at: Time.utc(2026, 7, 16, 12),
      )
    end

    it "returns the start time as a date in the event's time zone" do
      # 23:30 UTC July 13 is 09:30 July 14 in Sydney (UTC+10).
      expect(event.start_date).to eq(Date.new(2026, 7, 14))
    end
  end

  describe "#end_date" do
    let(:event) do
      build(
        :event,
        time_zone: "Australia/Sydney",
        starts_at: Time.utc(2026, 7, 13, 12),
        ends_at: Time.utc(2026, 7, 16, 23, 30),
      )
    end

    it "returns the end time as a date in the event's time zone" do
      # 23:30 UTC July 16 is 09:30 July 17 in Sydney (UTC+10).
      expect(event.end_date).to eq(Date.new(2026, 7, 17))
    end
  end

  describe "#current_date" do
    let(:event) { build(:event, time_zone: "Australia/Sydney") }

    it "returns 'today' as the date seen from the event's time zone" do
      # 23:30 UTC July 13 is July 14 in Sydney.
      travel_to(Time.utc(2026, 7, 13, 23, 30)) do
        expect(event.current_date).to eq(Date.new(2026, 7, 14))
      end
    end
  end

  describe "#happening_today?" do
    let(:zone) { "Australia/Sydney" }
    let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
    let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }
    let(:event) { build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at) }

    context "when today is before the event starts" do
      it "is false" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 13, 12)) do
          expect(event.happening_today?).to be(false)
        end
      end
    end

    context "when today is within the event window" do
      it "is true" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 15, 12)) do
          expect(event.happening_today?).to be(true)
        end
      end
    end

    context "when today is after the event ends" do
      it "is false" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 17, 12)) do
          expect(event.happening_today?).to be(false)
        end
      end
    end

    context "when 'now' in UTC has already crossed midnight in the event's zone" do
      # 23:30 UTC on July 13 is already July 14 in Sydney — so a Sydney
      # conference starting July 14 is happening today.
      it "uses the event's time zone, not UTC" do
        travel_to(Time.utc(2026, 7, 13, 23, 30)) do
          expect(event.happening_today?).to be(true)
        end
      end
    end

    context "when 'now' in UTC has crossed midnight but the event's zone hasn't" do
      # 01:30 UTC on July 14 is still July 13 in Honolulu (UTC-10) — so a
      # Honolulu conference starting July 14 is not yet happening.
      let(:zone) { "Pacific/Honolulu" }

      it "uses the event's time zone, not UTC" do
        travel_to(Time.utc(2026, 7, 14, 1, 30)) do
          expect(event.happening_today?).to be(false)
        end
      end
    end
  end

  describe "#current_day" do
    let(:zone) { "Australia/Sydney" }
    let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
    let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }
    let(:event) { build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at) }

    context "when today is before the event starts" do
      it "returns nil" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 13, 12)) do
          expect(event.current_day).to be_nil
        end
      end
    end

    context "when today is the first day of the event" do
      it "returns 1" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 14, 12)) do
          expect(event.current_day).to eq(1)
        end
      end
    end

    context "when today is the middle day of the event" do
      it "returns 2" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 15, 12)) do
          expect(event.current_day).to eq(2)
        end
      end
    end

    context "when today is the last day of the event" do
      it "returns the total day count" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 16, 12)) do
          expect(event.current_day).to eq(3)
        end
      end
    end

    context "when today is after the event ends" do
      it "returns nil" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 17, 12)) do
          expect(event.current_day).to be_nil
        end
      end
    end

    context "when 'now' in UTC is earlier than 'now' in the event's zone" do
      # 23:30 UTC on July 13 is already July 14 in Sydney — so for a
      # Sydney conference starting July 14, this is day 1, not day 0.
      it "uses the event's time zone to determine the current day" do
        travel_to(Time.utc(2026, 7, 13, 23, 30)) do
          expect(event.current_day).to eq(1)
        end
      end
    end

    context "when 'now' in UTC is later than 'now' in the event's zone" do
      # 01:30 UTC on July 14 is still July 13 in Honolulu (UTC-10) — so for a
      # Honolulu conference starting July 14, this is pre-event.
      let(:zone) { "Pacific/Honolulu" }
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }

      it "uses the event's time zone to determine the current day" do
        travel_to(Time.utc(2026, 7, 14, 1, 30)) do
          expect(event.current_day).to be_nil
        end
      end
    end

    context "when today is the only day of a single-day event" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 17) }

      it "returns 1" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 14, 12)) do
          expect(event.current_day).to eq(1)
        end
      end
    end
  end

  describe "#days_until_start" do
    let(:zone) { "Australia/Sydney" }
    let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
    let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }
    let(:event) { build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at) }

    context "with the event 12 days away" do
      it "returns 12" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 2, 12)) do
          expect(event.days_until_start).to eq(12)
        end
      end
    end

    context "with the event 1 day away" do
      it "returns 1" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 13, 12)) do
          expect(event.days_until_start).to eq(1)
        end
      end
    end

    context "with the event starting today" do
      it "returns 0" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 14, 12)) do
          expect(event.days_until_start).to eq(0)
        end
      end
    end

    context "when 'now' in UTC is earlier than 'now' in the event's zone" do
      # 23:30 UTC on July 12 is already July 13 in Sydney — one day from
      # the July 14 start, not two.
      it "uses the event's time zone to determine the day count" do
        travel_to(Time.utc(2026, 7, 12, 23, 30)) do
          expect(event.days_until_start).to eq(1)
        end
      end
    end

    context "when 'now' in UTC is later than 'now' in the event's zone" do
      # 01:30 UTC on July 14 is still July 13 in Honolulu (UTC-10) — so for a
      # Honolulu conference starting July 14, this is 1 day until start.
      let(:zone) { "Pacific/Honolulu" }
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }

      it "uses the event's time zone to determine the day count" do
        travel_to(Time.utc(2026, 7, 14, 1, 30)) do
          expect(event.days_until_start).to eq(1)
        end
      end
    end
  end

  describe "#upcoming?" do
    let(:zone) { "Australia/Sydney" }
    let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
    let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }
    let(:event) { build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at) }

    context "when the event is in the future" do
      it "returns true" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 1, 12)) do
          expect(event.upcoming?).to be(true)
        end
      end
    end

    context "when the event starts today" do
      it "returns false" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 14, 12)) do
          expect(event.upcoming?).to be(false)
        end
      end
    end

    context "when the event is in progress (mid-conference)" do
      it "returns false" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 15, 12)) do
          expect(event.upcoming?).to be(false)
        end
      end
    end

    context "when the event is in the past" do
      it "returns false" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 20, 12)) do
          expect(event.upcoming?).to be(false)
        end
      end
    end
  end

  describe "#past?" do
    let(:time_zone) { "Australia/Sydney" }
    let(:starts_at) { ActiveSupport::TimeZone[time_zone].local(2026, 7, 14, 9) }
    let(:ends_at) { ActiveSupport::TimeZone[time_zone].local(2026, 7, 16, 17) }
    let(:event) { build(:event, time_zone:, starts_at:, ends_at:) }

    context "when the event is in the future" do
      it "returns false" do
        travel_to(ActiveSupport::TimeZone[time_zone].local(2026, 7, 1, 12)) do
          expect(event.past?).to be(false)
        end
      end
    end

    context "when the event is in progress (mid-conference)" do
      it "returns false" do
        travel_to(ActiveSupport::TimeZone[time_zone].local(2026, 7, 15, 12)) do
          expect(event.past?).to be(false)
        end
      end
    end

    context "when the event ends today" do
      it "returns false" do
        travel_to(ActiveSupport::TimeZone[time_zone].local(2026, 7, 16, 12)) do
          expect(event.past?).to be(false)
        end
      end
    end

    context "when the event is in the past" do
      it "returns true" do
        travel_to(ActiveSupport::TimeZone[time_zone].local(2026, 7, 20, 12)) do
          expect(event.past?).to be(true)
        end
      end
    end
  end

  describe "#total_days" do
    let(:zone) { "Australia/Sydney" }
    let(:event) { build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at) }

    context "with a single-day event" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 17) }

      it "returns 1" do
        expect(event.total_days).to eq(1)
      end
    end

    context "with a 3-day event" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }

      it "returns 3" do
        expect(event.total_days).to eq(3)
      end
    end
  end
end
