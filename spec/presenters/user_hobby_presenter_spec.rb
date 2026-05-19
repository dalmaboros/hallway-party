# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserHobbyPresenter do
  describe "#hobby_name" do
    let(:user) { create(:user) }
    let(:hobby) { create(:hobby, name: "Knitting") }
    let(:user_hobby) { create(:user_hobby, user: user, hobby: hobby) }
    let(:presenter) { described_class.new(user_hobby) }

    it "returns the underlying hobby's name lowercased" do
      expect(presenter.hobby_name).to eq("knitting")
    end
  end

  describe "URL helper compatibility" do
    let(:user_hobby) { create(:user_hobby) }
    let(:presenter) { described_class.new(user_hobby) }

    it "delegates to_param so Rails URL helpers route through the underlying record" do
      expect(presenter.to_param).to eq(user_hobby.id.to_s)
    end
  end
end
