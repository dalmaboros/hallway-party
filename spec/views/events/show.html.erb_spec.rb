# frozen_string_literal: true

require "rails_helper"

RSpec.describe "events/show" do
  let(:user) { create(:user) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
    end
    stub_template "attendees/_attendee.html.erb" => "ATTENDEE"
    stub_template "events/_attendance_badge.html.erb" => "BADGE"
  end

  def assign_event(event)
    assign(:event_presenter, EventPresenter.new(event))
  end

  def assign_attendees(matched: [], others: [])
    assign(:matched_user_presenters, matched)
    assign(:other_user_presenters, others)
  end

  describe "status pill" do
    it "shows the countdown pill for an upcoming event", :aggregate_failures do
      assign_event(create(:event, :upcoming))
      render
      expect(rendered).to match(/Starts in \d+ days?/)
      expect(rendered).not_to match(/Day \d+ of \d+/)
    end

    it "shows the day-of pill for an in-progress event", :aggregate_failures do
      assign_event(create(:event, :in_progress))
      render
      expect(rendered).to match(/Day \d+ of \d+/)
      expect(rendered).not_to match(/Starts in \d+ days?/)
    end
  end

  describe "attendees section" do
    context "when the viewer attends an upcoming event" do
      let(:event) { create(:event, :upcoming) }

      before do
        create(:event_attendance, user:, event:)
        assign_event(event)
      end

      it "uses the Attendees heading" do
        assign_attendees
        render
        expect(rendered).to include("Attendees")
      end

      it "renders the shared-interests heading when there are matched attendees" do
        assign_attendees(matched: [UserPresenter.new(build_stubbed(:user))])
        render
        expect(rendered).to include("People who share your interests")
      end

      it "renders the everyone-else heading when there are other attendees" do
        assign_attendees(others: [UserPresenter.new(build_stubbed(:user))])
        render
        expect(rendered).to include("Everyone else")
      end

      it "shows the empty state when no other attendees exist" do
        assign_attendees
        render
        expect(rendered).to include("You're early")
      end

      it "renders the attendance badge" do
        assign_attendees
        render
        expect(rendered).to include("BADGE")
      end
    end

    context "when the viewer attends an in-progress event" do
      let(:event) { create(:event, :in_progress) }

      before do
        create(:event_attendance, user:, event:)
        assign_event(event)
        assign_attendees
      end

      it "uses the present-tense People here heading" do
        render
        expect(rendered).to include("People here")
      end
    end

    context "when the viewer does not attend the event" do
      before do
        assign_event(create(:event, :upcoming))
        assign_attendees
      end

      it "hides the attendees section", :aggregate_failures do
        render
        expect(rendered).not_to include("Attendees")
        expect(rendered).not_to include("You're early")
      end

      it "omits the attendance badge" do
        render
        expect(rendered).not_to include("BADGE")
      end
    end
  end
end
