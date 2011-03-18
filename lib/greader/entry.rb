module GReader
  # A feed entry.
  #
  # == Common usage
  #
  # Getting entries:
  #
  #   feed.entries.each do |entry|
  #     # ...
  #     assert entry.feed == feed
  #   end
  #
  #   # Or from tags...
  #   tag.entries.each { |entry| }
  #
  # Common metadata:
  #
  #   entry.title           #=> "On pride and prejudice" (or #to_s)
  #   entry.content         #=> "<p>There was a time where..."
  #
  # More metadata:
  #
  #   entry.author          #=> "Rico Sta. Cruz"
  #   entry.updated         #=> #<Date>
  #   entry.published       #=> #<Date>
  #   entry.url             #=> "http://ricostacruz.com/on-pride-and-prejudice.html"
  #
  # Relationships:
  #
  #   entry.feed            #=> #<Feed ...>
  #
  # States and actions:
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

    alias to_s title

    # Constructor.
    # Can be called with an options hash or a Nokogiri XML node.
    def initialize(client=Client.new, options)
      @client  = client

      @feed      = client.feed(options[:feed])
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

    # Converts a Noko XML node into a simpler Hash.
    def self.parse_json(doc)
      { :url       => doc['alternate'].first['href'],
        :author    => '(author unknown)',
        :content   => (doc['content'] || doc['summary'])['content'],
        :title     => doc['title'],
        :published => Time.new(doc['published']),
        :updated   => Time.new(doc['updated']),
        :feed      => doc['origin']['streamId']
      }
    end

    # tags (<category>), read?, starred?, etc
    # read! unread!
  end
end
