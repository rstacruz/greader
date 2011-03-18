module GReader
  # A feed entry.
  #
  # == Common usage
  #
  #   # Getting entries
  #   entry = feed.entries.first
  #   assert entry.feed == feed
  #
  #   # Or from tags...
  #   entry = tag.entries.first
  #
  #   # Common stuff
  #   entry.title           #=> "On pride and prejudice"
  #   entry.content         #=> "<p>There was a time where..."
  #
  #   # More metadata
  #   entry.author          #=> "Rico Sta. Cruz"
  #   entry.updated         #=> #<Date>
  #   entry.published       #=> #<Date>
  #   entry.url             #=> "http://ricostacruz.com/on-pride-and-prejudice.html"
  #
  #   # Etc
  #   entry.feed            #=> #<Feed ...>
  #
  #   # Not implemented yet!
  #   entry.read?           # Read or not?
  #   entry.starred?
  #
  #   entry.read!           # Mark as read
  #   entry.unread!         # Mark as unread
  #
  class Entry
    attr_reader :content
    attr_reader :author
    attr_reader :title
    attr_reader :published
    attr_reader :updated
    attr_reader :url

    attr_reader :feed
    attr_reader :client

    def initialize(feed=Feed.new, options)
      @feed    = feed
      @client  = feed.client

      @author    = options[:author]
      @content   = options[:content]
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
