# frozen_string_literal: true

require "rails_helper"

RSpec.describe HobbyPresenter do
  describe "#name" do
    let(:presenter) { described_class.new(build(:hobby, name: stored_name)) }

    context "with a mixed-case name" do
      let(:stored_name) { "Knitting" }

      it "returns the name lowercased" do
        expect(presenter.name).to eq("knitting")
      end
    end

    context "with a nil name" do
      let(:stored_name) { nil }

      it "returns nil" do
        expect(presenter.name).to be_nil
      end
    end
  end

  describe "#pill_classes" do
    let(:presenter) { described_class.new(build(:hobby)) }

    context "when shared" do
      it "includes the soft background class from the chosen theme" do
        expect(presenter.pill_classes(shared: true)).to match(/bg-party-\w+-soft/)
      end

      it "includes the border class from the chosen theme" do
        expect(presenter.pill_classes(shared: true)).to match(/border-party-\w+/)
      end
    end

    context "when not shared" do
      it "uses the muted gray variant" do
        expect(presenter.pill_classes(shared: false)).to include("bg-gray-100", "border-gray-200")
      end
    end

    it "always includes the base pill classes" do
      expect(presenter.pill_classes).to include("inline-block", "rounded-full", "px-3", "py-1")
    end
  end

  describe "#shared_with?" do
    let(:hobby) { create(:hobby, name: "knitting") }
    let(:presenter) { described_class.new(hobby) }
    let(:user) { create(:user) }

    context "when the user has the hobby" do
      before { user.hobbies << hobby }

      it "returns true" do
        expect(presenter.shared_with?(user)).to be(true)
      end
    end

    context "when the user does not have the hobby" do
      it "returns false" do
        expect(presenter.shared_with?(user)).to be(false)
      end
    end
  end
end
