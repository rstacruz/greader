module GReader
  module Utilities
    extend self

    def escape(str)
      CGI.escape(str).gsub('+', '%20')
    end
  end
end
