# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgrammingHobbyFilter do
  describe ".programming?" do
    context "with programming-related hobbies" do
      [
        "Ruby",
        "rails",
        "Python",
        "JavaScript",
        "programming",
        "coding",
        "software development",
        "DevOps",
        "machine learning",
        "web development",
        "full stack",
        "Docker",
        "kubernetes",
      ].each do |name|
        it "flags #{name.inspect}" do
          expect(described_class.programming?(name)).to be true
        end
      end

      it "flags terms embedded in a longer phrase" do
        expect(described_class.programming?("teaching my kid Python")).to be true
      end

      it "ignores surrounding whitespace" do
        expect(described_class.programming?("  ruby  ")).to be true
      end

      it "is case-insensitive" do
        expect(described_class.programming?("MACHINE LEARNING")).to be true
      end
    end

    context "with legitimate hobbies" do
      [
        "knitting",
        "hiking",
        "board games",
        "photography",
        "pottery",
        "cycling",
        "cooking",
        "reading",
        "gardening",
        "rock climbing",
        "creative writing",
        "birdwatching",
      ].each do |name|
        it "does not flag #{name.inspect}" do
          expect(described_class.programming?(name)).to be false
        end
      end
    end

    context "with words that embed a denylist term as a substring" do
      # Regression: an earlier implementation used `include?` and wrongly
      # flagged these because "ai", "go", "rust", "git" appeared inside.
      [
        "painting", # embeds "ai"
        "tango",    # embeds "go"
        "trust",    # embeds "rust"
        "digit",    # embeds "git"
      ].each do |name|
        it "does not flag #{name.inspect}" do
          expect(described_class.programming?(name)).to be false
        end
      end
    end

    context "with edge inputs" do
      it "returns false for nil" do
        expect(described_class.programming?(nil)).to be false
      end

      it "returns false for an empty string" do
        expect(described_class.programming?("")).to be false
      end

      it "returns false for whitespace only" do
        expect(described_class.programming?("   ")).to be false
      end
    end
  end
end
