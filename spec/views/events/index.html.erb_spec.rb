# frozen_string_literal: true

require "rails_helper"

RSpec.describe "events/index" do
  let(:user) { create(:user) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
    end
  end

  def assign_presenters(upcoming_events: [], past_events: [])
    assign(:upcoming_event_presenters, upcoming_events.map { |event| EventPresenter.new(event) })
    assign(:past_event_presenters, past_events.map { |event| EventPresenter.new(event) })
  end

  context "with both upcoming and past events" do
    before do
      assign_presenters(upcoming_events: [create(:event, :upcoming)], past_events: [create(:event, :past)])
      render
    end

    it "renders the upcoming and past sections", :aggregate_failures do
      expect(rendered).to include('id="upcoming-events"')
      expect(rendered).to include('id="past-events"')
    end

    it "stacks the upcoming section above the past section" do
      expect(rendered.index("upcoming-events")).to be < rendered.index("past-events")
    end
  end

  context "with no upcoming events" do
    before do
      assign_presenters(past_events: [create(:event, :past)])
      render
    end

    it "shows the upcoming empty state" do
      expect(rendered).to include("No upcoming events yet.")
    end
  end

  context "with no past events" do
    before do
      assign_presenters(upcoming_events: [create(:event, :upcoming)])
      render
    end

    it "omits the past section" do
      expect(rendered).not_to include('id="past-events"')
    end
  end
end
