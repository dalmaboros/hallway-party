# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventPresenter do
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
end
