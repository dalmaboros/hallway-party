# frozen_string_literal: true

require "rails_helper"

RSpec.describe AttendeeMatcher do
  # Hand-crafted 1536-d vectors so similarity is predictable without a real
  # OpenAI call. Axis 0 = "craft-like", axis 1 = "outdoor-like".
  def vector(craft: 0.0, outdoor: 0.0)
    values = Array.new(Embedder::DIMENSIONS, 0.0)
    values[0] = craft
    values[1] = outdoor
    values
  end

  let(:event) { create(:event, :upcoming) }
  let(:viewer) { create(:user, name: "Zara Viewer") }

  before { create(:event_attendance, user: viewer, event: event) }

  def match
    described_class.new(user: viewer, event: event).match_attendees
  end

  describe "#match_attendees" do
    context "with embedded user hobbies and embedded attendee hobbies" do
      let(:crafter) { create(:user, name: "Alex") }
      let(:hiker) { create(:user, name: "Blair") }
      let(:fiber_arts) { create(:hobby, name: "fiber arts", embedding: vector(craft: 0.99, outdoor: 0.01)) }

      before do
        knitting = create(:hobby, name: "knitting", embedding: vector(craft: 1.0))
        hiking = create(:hobby, name: "hiking", embedding: vector(outdoor: 1.0))
        create(:user_hobby, user: viewer, hobby: knitting)
        create(:event_attendance, user: crafter, event: event)
        create(:event_attendance, user: hiker, event: event)
        create(:user_hobby, user: crafter, hobby: fiber_arts)
        create(:user_hobby, user: hiker, hobby: hiking)
      end

      it "ranks the crafter for a knitter and drops the hiker as noise" do
        expect(match.map(&:id)).to eq([crafter.id])
      end

      it "excludes the viewer" do
        expect(match).not_to include(viewer)
      end

      it "excludes attendees of other events" do
        other_event = create(:event, :upcoming, name: "Different Conf")
        other_attendee = create(:user, name: "Chris")
        create(:event_attendance, user: other_attendee, event: other_event)
        create(:user_hobby, user: other_attendee, hobby: fiber_arts)

        expect(match).not_to include(other_attendee)
      end
    end

    context "when the viewer has no embedded hobbies" do
      before do
        create(:event_attendance, user: create(:user, name: "Alice"), event: event)
        create(:event_attendance, user: create(:user, name: "Bob"), event: event)
      end

      it "returns an empty array since ranking by similarity is impossible" do
        expect(match).to eq([])
      end
    end

    context "when no other attendees exist" do
      it "returns an empty array" do
        knitting = create(:hobby, name: "knitting", embedding: vector(craft: 1.0))
        create(:user_hobby, user: viewer, hobby: knitting)
        expect(match).to eq([])
      end
    end
  end
end
