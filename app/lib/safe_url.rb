# frozen_string_literal: true

# Returns the URL only if it parses as an http(s) URL, else nil.
# Use whenever rendering a user- or admin-supplied URL into an href to
# prevent javascript: and data: scheme XSS.
module SafeUrl
  class << self
    def parse(url)
      url if url.to_s.match?(%r{\Ahttps?://}i)
    end
  end
end
