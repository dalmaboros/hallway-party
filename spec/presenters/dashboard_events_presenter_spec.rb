# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardEventsPresenter do
  subject(:presenter) { described_class.new(user) }

  let(:user) { create(:user) }

  describe "#banner_state" do
    context "with a future event that is not happening today" do
      before { user.events << create(:event, :upcoming) }

      it "is :upcoming" do
        expect(presenter.banner_state).to eq(:upcoming)
      end
    end

    context "with an event happening today" do
      before { user.events << create(:event, :in_progress) }

      it "is :happening_today" do
        expect(presenter.banner_state).to eq(:happening_today)
      end
    end

    context "with only past attendance" do
      before { user.events << create(:event, :past) }

      it "is :soft_sunset" do
        expect(presenter.banner_state).to eq(:soft_sunset)
      end
    end

    context "with no events at all" do
      it "is :no_events" do
        expect(presenter.banner_state).to eq(:no_events)
      end
    end
  end

  describe "#next_event" do
    context "when an upcoming event exists" do
      let(:event) { create(:event, :upcoming) }

      before { user.events << event }

      it "wraps it in an EventPresenter" do
        aggregate_failures do
          expect(presenter.next_event).to be_a(EventPresenter)
          expect(presenter.next_event.event).to eq(event)
        end
      end
    end

    context "when no upcoming event exists" do
      before { user.events << create(:event, :past) }

      it "is nil" do
        expect(presenter.next_event).to be_nil
      end
    end
  end

  describe "#most_recent_past_event" do
    context "when a past event exists" do
      let(:event) { create(:event, :past) }

      before { user.events << event }

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
    it "wraps each upcoming event in an EventPresenter" do
      user.events << create(:event, :upcoming)

      aggregate_failures do
        expect(presenter.upcoming_events).to all(be_a(EventPresenter))
        expect(presenter.upcoming_events.size).to eq(1)
      end
    end
  end
end
