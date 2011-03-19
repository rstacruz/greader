module GReader
  module Utilities
    extend self

    def escape(str)
      CGI.escape(str).gsub('+', '%20')
    end

    def slug(str)
      str.gsub(/[\/\?=&]/, '_')
    end

    def strip_tags(str)
      str.gsub(%r{</?[^>]+?>}, '')
    end
  end
end
