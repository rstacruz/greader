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
    
    def kv_map(hash)
      hash.map { |k, v| '%s=%s' % [CGI.escape(k.to_s), URI.escape(v.to_s)] }.join('&')
    end
  end
end
