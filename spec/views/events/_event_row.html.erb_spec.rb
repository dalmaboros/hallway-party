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

  def render_row(event)
    render partial: "events/event_row", locals: { event_presenter: EventPresenter.new(event) }
  end

  context "when the viewer attends the event" do
    let(:attended_event) { create(:event, :upcoming) }

    before { create(:event_attendance, user:, event: attended_event) }

    it "renders the attendance badge" do
      render_row(attended_event)
      expect(rendered).to include("BADGE")
    end
  end

  context "when the viewer does not attend the event" do
    let(:unattended_event) { create(:event, :upcoming) }

    it "omits the attendance badge" do
      render_row(unattended_event)
      expect(rendered).not_to include("BADGE")
    end
  end
end
