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

  def assign_event_presenter(event)
    assign(:event_presenter, EventPresenter.new(event))
  end

  def assign_user_presenters(matched: [], others: [])
    assign(:matched_user_presenters, matched)
    assign(:other_user_presenters, others)
  end

  describe "status pill" do
    before do
      assign_event_presenter(event)
      render
    end

    context "when the event is upcoming" do
      let(:event) { create(:event, :upcoming) }

      it "shows only the countdown pill", :aggregate_failures do
        expect(rendered).to match(/Starts in \d+ days?/)
        expect(rendered).not_to match(/Day \d+ of \d+/)
      end
    end

    context "when the event is in progress" do
      let(:event) { create(:event, :in_progress) }

      it "shows only the day-of pill", :aggregate_failures do
        expect(rendered).to match(/Day \d+ of \d+/)
        expect(rendered).not_to match(/Starts in \d+ days?/)
      end
    end
  end

  describe "attendees section" do
    context "when the viewer attends an upcoming event" do
      let(:event) { create(:event, :upcoming) }

      before do
        create(:event_attendance, user:, event:)
        assign_event_presenter(event)
      end

      it "uses the Attendees heading" do
        assign_user_presenters
        render
        expect(rendered).to include("Attendees")
      end

      it "renders the shared-interests heading when there are matched attendees" do
        assign_user_presenters(matched: [UserPresenter.new(build_stubbed(:user))])
        render
        expect(rendered).to include("People who share your interests")
      end

      it "renders the everyone-else heading when there are other attendees" do
        assign_user_presenters(others: [UserPresenter.new(build_stubbed(:user))])
        render
        expect(rendered).to include("Everyone else")
      end

      it "shows the empty state when no other attendees exist" do
        assign_user_presenters
        render
        expect(rendered).to include("You're early")
      end

      it "renders the attendance badge" do
        assign_user_presenters
        render
        expect(rendered).to include("BADGE")
      end
    end

    context "when the viewer attends an in-progress event" do
      let(:event) { create(:event, :in_progress) }

      before do
        create(:event_attendance, user:, event:)
        assign_event_presenter(event)
        assign_user_presenters
      end

      it "uses the present-tense People here heading" do
        render
        expect(rendered).to include("People here")
      end
    end

    context "when the viewer does not attend the event" do
      before { assign_event_presenter(create(:event, :upcoming)) }

      it "shows the attendees heading and the gate message, but no attendees", :aggregate_failures do
        render
        expect(rendered).to include("Attendees")
        expect(rendered).to include("You can see the conference attendees only if you are attending as well!")
        expect(rendered).not_to include("ATTENDEE")
        expect(rendered).not_to include("You're early")
      end

      it "omits the attendance badge" do
        render
        expect(rendered).not_to include("BADGE")
      end
    end
  end

  describe "attendance toggle" do
    context "when the event is upcoming and the viewer attends" do
      let(:event) { create(:event, :upcoming) }

      before do
        create(:event_attendance, user:, event:)
        assign_event_presenter(event)
        assign_user_presenters
      end

      it "offers to cancel attendance", :aggregate_failures do
        render
        expect(rendered).to include(event_attendance_path(event))
        expect(rendered).to include('value="delete"')
      end
    end

    context "when the event is upcoming and the viewer does not attend" do
      let(:event) { create(:event, :upcoming) }

      before { assign_event_presenter(event) }

      it "offers to attend", :aggregate_failures do
        render
        expect(rendered).to include(event_attendance_path(event))
        expect(rendered).not_to include('value="delete"')
      end
    end

    context "when the event is past" do
      let(:event) { create(:event, :past) }

      before { assign_event_presenter(event) }

      it "offers no attendance control" do
        render
        expect(rendered).not_to include(event_attendance_path(event))
      end
    end
  end
end
