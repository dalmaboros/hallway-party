# frozen_string_literal: true

require "rails_helper"

RSpec.describe SafeUrl do
  describe ".parse" do
    subject(:parsed) { described_class.parse(url) }

    context "with an http URL" do
      let(:url) { "http://example.com" }

      it "returns it unchanged" do
        expect(parsed).to eq("http://example.com")
      end
    end

    context "with an https URL" do
      let(:url) { "https://example.com" }

      it "returns it unchanged" do
        expect(parsed).to eq("https://example.com")
      end
    end

    context "with a javascript: URL" do
      let(:url) { "javascript:alert(1)" }

      it "returns nil to prevent XSS" do
        expect(parsed).to be_nil
      end
    end

    context "with a data: URL" do
      let(:url) { "data:text/html,<script>" }

      it "returns nil to prevent XSS" do
        expect(parsed).to be_nil
      end
    end

    context "with nil input" do
      let(:url) { nil }

      it "returns nil" do
        expect(parsed).to be_nil
      end
    end

    context "with an empty string" do
      let(:url) { "" }

      it "returns nil" do
        expect(parsed).to be_nil
      end
    end
  end
end
