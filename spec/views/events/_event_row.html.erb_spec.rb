# frozen_string_literal: true

require "rails_helper"

RSpec.describe "events/_event_row" do
  let(:user) { create(:user) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_user).and_return(user)
    end
    stub_template "events/_attendance_badge.html.erb" => "BADGE"
  end

  def render_row(event, attendable: false)
    render partial: "events/event_row",
      locals: { event_presenter: EventPresenter.new(event), attendable: }
  end

  context "when the viewer attends the event" do
    let(:attended_event) { create(:event, :upcoming) }

    before { create(:event_attendance, user:, event: attended_event) }

    it "renders the attendance badge" do
      render_row(attended_event)
      expect(rendered).to include("BADGE")
    end

    it "offers to cancel attendance when the event is attendable", :aggregate_failures do
      render_row(attended_event, attendable: true)
      expect(rendered).to include(event_attendance_path(attended_event))
      expect(rendered).to include("Cancel")
      expect(rendered).to include('value="delete"')
    end
  end

  context "when the viewer does not attend the event" do
    let(:unattended_event) { create(:event, :upcoming) }

    it "omits the attendance badge" do
      render_row(unattended_event)
      expect(rendered).not_to include("BADGE")
    end

    it "offers to attend when the event is attendable", :aggregate_failures do
      render_row(unattended_event, attendable: true)
      expect(rendered).to include(event_attendance_path(unattended_event))
      expect(rendered).to include("Attend")
    end

    it "offers no attend control when the event is not attendable" do
      render_row(unattended_event, attendable: false)
      expect(rendered).not_to include("Attend")
    end
  end
end
