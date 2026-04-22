# frozen_string_literal: true

class ProgrammingHobbyFilter
  DENYLIST = [
    "ruby",
    "rails",
    "python",
    "javascript",
    "typescript",
    "java",
    "kotlin",
    "go",
    "golang",
    "rust",
    "swift",
    "php",
    "scala",
    "clojure",
    "haskell",
    "elixir",
    "erlang",
    "programming",
    "coding",
    "software",
    "development",
    "engineering",
    "hacking",
    "devops",
    "docker",
    "kubernetes",
    "git",
    "github",
    "gitlab",
    "aws",
    "azure",
    "gcp",
    "cloud",
    "database",
    "sql",
    "nosql",
    "postgres",
    "postgresql",
    "mongodb",
    "redis",
    "elasticsearch",
    "frontend",
    "backend",
    "fullstack",
    "full stack",
    "web development",
    "webdev",
    "machine learning",
    "artificial intelligence",
    "ai",
    "ml",
    "linux",
    "unix",
    "vim",
    "emacs",
  ].freeze

  class << self
    def programming?(hobby_name)
      normalized = hobby_name.to_s.downcase.strip
      return false if normalized.empty?

      DENYLIST.any? { |term| /\b#{Regexp.escape(term)}\b/.match?(normalized) }
    end
  end
end
