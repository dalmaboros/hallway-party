# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventPresenter do
  describe "delegations" do
    let(:presenter) { described_class.new(build(:event)) }
    let(:delegated_methods) do
      [
        :name,
        :location,
        :start_date,
        :end_date,
        :current_date,
        :happening_today?,
        :current_day,
        :days_until_start,
        :upcoming?,
        :past?,
        :total_days,
      ]
    end

    it "delegates the listed methods to event" do
      aggregate_failures do
        delegated_methods.each do |method|
          expect(presenter).to delegate_method(method).to(:event)
        end
      end
    end
  end

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

  describe "#short_date_range" do
    let(:zone) { "America/Los_Angeles" }
    let(:presenter) { described_class.new(build(:event, time_zone: zone, starts_at: starts_at, ends_at: ends_at)) }

    context "with start and end on the same day" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 5, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 5, 17) }

      it "returns the single date" do
        expect(presenter.short_date_range).to eq("Nov 5, 2026")
      end
    end

    context "with start and end in the same month" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 5, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 7, 17) }

      it "collapses to a day-range" do
        expect(presenter.short_date_range).to eq("Nov 5–7, 2026")
      end
    end

    context "with start and end crossing months" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 11, 30, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2026, 12, 2, 17) }

      it "abbreviates both endpoints" do
        expect(presenter.short_date_range).to eq("Nov 30, 2026 – Dec 2, 2026")
      end
    end

    context "with start and end crossing years" do
      let(:starts_at) { ActiveSupport::TimeZone[zone].local(2026, 12, 30, 9) }
      let(:ends_at) { ActiveSupport::TimeZone[zone].local(2027, 1, 2, 17) }

      it "abbreviates both endpoints with their respective years" do
        expect(presenter.short_date_range).to eq("Dec 30, 2026 – Jan 2, 2027")
      end
    end

    context "with the event in a non-default time zone" do
      # 23:30 UTC is the next day in Tokyo — proves the formatter uses the
      # event's own time zone rather than UTC or the system zone.
      let(:zone) { "Asia/Tokyo" }
      let(:starts_at) { Time.utc(2026, 11, 5, 23, 30) }
      let(:ends_at) { Time.utc(2026, 11, 5, 23, 45) }

      it "formats using the event's time zone, not the system zone" do
        expect(presenter.short_date_range).to eq("Nov 6, 2026")
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

  describe "#attendance_statement" do
    let(:presenter) { described_class.new(event) }

    context "when the event is in the past" do
      let(:event) { build(:event, :past) }

      it "uses the past tense" do
        expect(presenter.attendance_statement).to eq("You attended")
      end
    end

    context "when the event is not in the past" do
      let(:event) { build(:event, :upcoming) }

      it "uses the present tense" do
        expect(presenter.attendance_statement).to eq("You're attending")
      end
    end
  end

  describe "#attend_label" do
    let(:presenter) { described_class.new(event) }

    context "when the event is past" do
      let(:event) { build(:event, :past) }

      it "returns past tense CTA" do
        expect(presenter.attend_label).to eq("I attended")
      end
    end

    context "when the event is not past" do
      let(:event) { build(:event, :upcoming) }

      it "returns present tense CTA" do
        expect(presenter.attend_label).to eq("I am attending!")
      end
    end
  end

  describe "#remove_attendance_label" do
    let(:presenter) { described_class.new(event) }

    context "when the event is past" do
      let(:event) { build(:event, :past) }

      it "returns the retroactive removal label" do
        expect(presenter.remove_attendance_label).to eq("(Actually, I didn't go)")
      end
    end

    context "when the event is not past" do
      let(:event) { build(:event, :upcoming) }

      it "returns the cancellation label" do
        expect(presenter.remove_attendance_label).to eq("Cancel attendance")
      end
    end
  end
end
