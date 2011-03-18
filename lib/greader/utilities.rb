module GReader
  module Utilities
    extend self

    def escape(str)
      CGI.escape(str).gsub('+', '%20')
    end

    def slug(str)
      str.gsub('/', '_')
    end
  end
end
