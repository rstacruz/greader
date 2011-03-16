module GReader
  class Entry
    attr_reader :summary
    attr_reader :author
    attr_reader :title
    attr_reader :published
    attr_reader :updated
    attr_reader :url

    def initialize(feed=Feed.new, options)
      @feed    = feed
      @client  = feed.client

      @author    = options[:author]
      @summary   = options[:summary]
      @title     = options[:title]
      @published = options[:published]
      @updated   = options[:updated]
      @url       = options[:url]
      @options = options
    end

    def inspect
      "#<#{self.class.name} \"#{title}\" (#{url})>"
    end
    # tags (<category>), read?, starred?, etc
    # read! unread!
  end
end
