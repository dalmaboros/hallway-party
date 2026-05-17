# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPresenter do
  describe "#initials" do
    let(:presenter) { described_class.new(build(:user, name: name)) }

    context "with a two-name user" do
      let(:name) { "Mona Octocat" }

      it "returns first+last capitalized initials" do
        expect(presenter.initials).to eq("MO")
      end
    end

    context "with a one-name user" do
      let(:name) { "Mona" }

      it "returns the single capitalized initial" do
        expect(presenter.initials).to eq("M")
      end
    end

    context "with three or more name parts" do
      let(:name) { "Jose Maria Octocat" }

      it "returns first+last initials" do
        expect(presenter.initials).to eq("JO")
      end
    end

    context "with a blank name" do
      let(:name) { "" }

      it "returns an empty string" do
        expect(presenter.initials).to eq("")
      end
    end

    context "with a lowercase name" do
      let(:name) { "mona octocat" }

      it "uppercases the initials" do
        expect(presenter.initials).to eq("MO")
      end
    end
  end

  describe "#website" do
    let(:presenter) { described_class.new(build(:user, website: stored_website)) }

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

  describe "#avatar_color_class" do
    let(:user) { build(:user, username: "user") }
    let(:presenter) { described_class.new(user) }

    it "returns one of the AVATAR_BG_CLASSES" do
      expect(described_class::AVATAR_BG_CLASSES).to include(presenter.avatar_color_class)
    end

    it "is deterministic for the same username" do
      expect(presenter.avatar_color_class).to eq(described_class.new(user).avatar_color_class)
    end
  end

  describe "#shared_hobbies" do
    let(:user) { create(:user) }
    let(:presenter) { described_class.new(user) }
    let!(:knitting) { create(:hobby, name: "knitting") }
    let!(:cycling) { create(:hobby, name: "cycling") }
    let!(:sourdough) { create(:hobby, name: "sourdough") }

    before { user.hobbies << [knitting, cycling, sourdough] }

    context "when the current user shares none of the user's hobbies" do
      it "returns an empty array" do
        expect(presenter.shared_hobbies([])).to eq([])
      end
    end

    context "when the current user shares a subset of the user's hobbies" do
      it "returns just the shared ones, sorted alphabetically" do
        expect(presenter.shared_hobbies([knitting.id, cycling.id])).to eq([cycling, knitting])
      end
    end

    context "when the current user shares every one of the user's hobbies" do
      it "returns all of them, sorted alphabetically" do
        expect(presenter.shared_hobbies([knitting.id, cycling.id, sourdough.id])).to eq([cycling, knitting, sourdough])
      end
    end

    context "when the current user's ids include hobbies the user does not have" do
      it "ignores the unrelated ids" do
        unrelated = create(:hobby, name: "rock climbing")
        expect(presenter.shared_hobbies([unrelated.id])).to eq([])
      end
    end
  end

  describe "#other_hobbies" do
    let(:user) { create(:user) }
    let(:presenter) { described_class.new(user) }
    let!(:knitting) { create(:hobby, name: "knitting") }
    let!(:cycling) { create(:hobby, name: "cycling") }
    let!(:sourdough) { create(:hobby, name: "sourdough") }

    before { user.hobbies << [knitting, cycling, sourdough] }

    context "when the current user shares none of the user's hobbies" do
      it "returns all of them, sorted alphabetically" do
        expect(presenter.other_hobbies([])).to eq([cycling, knitting, sourdough])
      end
    end

    context "when the current user shares a subset of the user's hobbies" do
      it "returns just the non-shared ones, sorted alphabetically" do
        expect(presenter.other_hobbies([knitting.id, cycling.id])).to eq([sourdough])
      end
    end

    context "when the current user shares every one of the user's hobbies" do
      it "returns an empty array" do
        expect(presenter.other_hobbies([knitting.id, cycling.id, sourdough.id])).to eq([])
      end
    end
  end
end
