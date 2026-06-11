# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardEventsPresenter do
  subject(:presenter) { described_class.new(user) }

  let(:user) { create(:user) }

  describe "#attendance_status" do
    context "with a future event the user is attending" do
      before do
        create(:event_attendance, user:, event: create(:event, :upcoming))
      end

      it "is :upcoming_attending" do
        expect(presenter.attendance_status).to eq(:upcoming_attending)
      end
    end

    context "with a future event the user is not attending" do
      before { create(:event, :upcoming) }

      it "is :upcoming_not_attending" do
        expect(presenter.attendance_status).to eq(:upcoming_not_attending)
      end
    end

    context "with a today's event the user is attending" do
      before do
        create(:event_attendance, user:, event: create(:event, :in_progress))
      end

      it "is :happening_today" do
        expect(presenter.attendance_status).to eq(:happening_today)
      end
    end

    context "with a today's event the user is not attending" do
      before { create(:event, :in_progress) }

      it "is :happening_today_not_attending" do
        expect(presenter.attendance_status).to eq(:happening_today_not_attending)
      end
    end

    context "with only past attendance" do
      before { create(:event_attendance, user:, event: create(:event, :past)) }

      it "is :soft_sunset" do
        expect(presenter.attendance_status).to eq(:soft_sunset)
      end
    end

    context "with no events at all" do
      it "is :no_events" do
        expect(presenter.attendance_status).to eq(:no_events)
      end
    end
  end

  describe "#next_event" do
    context "when a global upcoming event exists (not attended by user)" do
      let(:event) { create(:event, :upcoming) }

      before { event }

      it "wraps it in an EventPresenter" do
        aggregate_failures do
          expect(presenter.next_event).to be_a(EventPresenter)
          expect(presenter.next_event.event).to eq(event)
        end
      end
    end

    context "when no upcoming events exist anywhere" do
      it "is nil" do
        expect(presenter.next_event).to be_nil
      end
    end
  end

  describe "#most_recent_past_event" do
    context "when a past event exists that the user attended" do
      let(:event) { create(:event, :past) }

      before { create(:event_attendance, user:, event:) }

      it "wraps it in an EventPresenter" do
        aggregate_failures do
          expect(presenter.most_recent_past_event).to be_a(EventPresenter)
          expect(presenter.most_recent_past_event.event).to eq(event)
        end
      end
    end

    context "when no past event exists" do
      it "is nil rather than a presenter wrapping nil" do
        expect(presenter.most_recent_past_event).to be_nil
      end
    end
  end

  describe "#upcoming_events" do
    it "wraps each upcoming event the user attends in an EventPresenter" do
      create(:event_attendance, user:, event: create(:event, :upcoming))

      aggregate_failures do
        expect(presenter.upcoming_events).to all(be_a(EventPresenter))
        expect(presenter.upcoming_events.size).to eq(1)
      end
    end
  end
end
