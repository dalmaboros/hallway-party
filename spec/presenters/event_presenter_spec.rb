# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventPresenter do
  describe "#website" do
    let(:presenter) { described_class.new(build(:event, website: stored_website)) }

    context "with an https URL" do
      let(:stored_website) { "https://example.com" }

      it "returns it" do
        expect(presenter.website).to eq("https://example.com")
      end
    end

    context "with a javascript: URL" do
      let(:stored_website) { "javascript:alert(1)" }

      it "returns nil to prevent XSS" do
        expect(presenter.website).to be_nil
      end
    end

    context "with a blank website" do
      let(:stored_website) { "" }

      it "returns nil" do
        expect(presenter.website).to be_nil
      end
    end
  end

  describe "#date_range" do
    let(:zone) { "America/Los_Angeles" }
    let(:presenter) { described_class.new(build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at)) }

    context "with start and end on the same day" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 5, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 5, 17) }

      it "returns the single date" do
        expect(presenter.date_range).to eq("November 5, 2026")
      end
    end

    context "with start and end in the same month" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 5, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 7, 17) }

      it "collapses to a day-range" do
        expect(presenter.date_range).to eq("November 5–7, 2026")
      end
    end

    context "with start and end crossing months" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 30, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 12, 2, 17) }

      it "spells out both endpoints" do
        expect(presenter.date_range).to eq("November 30, 2026 – December 2, 2026")
      end
    end

    context "with start and end crossing years" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 12, 30, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2027, 1, 2, 17) }

      it "spells out both endpoints with their respective years" do
        expect(presenter.date_range).to eq("December 30, 2026 – January 2, 2027")
      end
    end

    context "with the event in a non-default time zone" do
      # 23:30 UTC is the next day in Tokyo — proves the formatter uses the
      # event's own time zone rather than UTC or the system zone.
      let(:zone) { "Asia/Tokyo" }
      let(:starts_at) { Time.utc(2026, 11, 5, 23, 30) }
      let(:ends_at) { Time.utc(2026, 11, 5, 23, 45) }

      it "formats using the event's time zone, not the system zone" do
        expect(presenter.date_range).to eq("November 6, 2026")
      end
    end
  end

  describe "#current_day" do
    let(:zone) { "Australia/Sydney" }
    let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
    let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }
    let(:presenter) { described_class.new(build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at)) }

    context "when today is before the event starts" do
      it "returns nil" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 13, 12)) do
          expect(presenter.current_day).to be_nil
        end
      end
    end

    context "when today is the first day of the event" do
      it "returns 1" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 14, 12)) do
          expect(presenter.current_day).to eq(1)
        end
      end
    end

    context "when today is the middle day of the event" do
      it "returns 2" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 15, 12)) do
          expect(presenter.current_day).to eq(2)
        end
      end
    end

    context "when today is the last day of the event" do
      it "returns the total day count" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 16, 12)) do
          expect(presenter.current_day).to eq(3)
        end
      end
    end

    context "when today is after the event ends" do
      it "returns nil" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 17, 12)) do
          expect(presenter.current_day).to be_nil
        end
      end
    end

    context "when 'now' in UTC is earlier than 'now' in the event's zone" do
      # 23:30 UTC on July 13 is already July 14 in Sydney — so for a
      # Sydney conference starting July 14, this is day 1, not day 0.
      it "uses the event's time zone to determine the current day" do
        travel_to(Time.utc(2026, 7, 13, 23, 30)) do
          expect(presenter.current_day).to eq(1)
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
          expect(presenter.current_day).to be_nil
        end
      end
    end

    context "when today is the only day of a single-day event" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 17) }

      it "returns 1" do
        travel_to(ActiveSupport::TimeZone[zone].local(2026, 7, 14, 12)) do
          expect(presenter.current_day).to eq(1)
        end
      end
    end
  end

  describe "#total_days" do
    let(:zone) { "Australia/Sydney" }
    let(:presenter) { described_class.new(build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at)) }

    context "with a single-day event" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 17) }

      it "returns 1" do
        expect(presenter.total_days).to eq(1)
      end
    end

    context "with a 3-day event" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 14, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 7, 16, 17) }

      it "returns 3" do
        expect(presenter.total_days).to eq(3)
      end
    end
  end

  describe "#attended_by?" do
    let(:event) { create(:event) }
    let(:presenter) { described_class.new(event) }
    let(:user) { create(:user) }

    context "when the user attends the event" do
      before { user.events << event }

      it "returns true" do
        expect(presenter.attended_by?(user)).to be(true)
      end
    end

    context "when the user does not attend the event" do
      it "returns false" do
        expect(presenter.attended_by?(user)).to be(false)
      end
    end
  end
end
