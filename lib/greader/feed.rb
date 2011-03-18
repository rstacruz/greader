module GReader
  # A feed is a collection of entries.
  #
  # == Common usage
  #
  # Getting feeds:
  #
  #   feed = client.feed('FEED_ID')
  #
  # Common metadata:
  #
  #   feed.title        #=> "Rico's blog" (or #to_s)
  #   feed.url          #=> "http://ricostacruz.com"
  #   feed.id           #=> "feed/http://ricostacruz.com" (from Google)
  #
  # Collections:
  #
  #   feed.entries      #=> [#<Entry>, ...]
  #   feed.tags         #=> [#<Tag>, ...]
  #
  # Other ways of getting feeds:
  #
  #   client.feeds.each { |feed| }
  #   client.tag('TAG_ID').feeds.each { |feed| }
  #
  # :stopdoc:
  # This is what Google spits out as JSON.
  #
  #   id: feed/http://xkcd.com/rss.xml
  #   title: xkcd.com
  #   categories: 
  #   - id: user/05185502537486227907/label/Misc | Comics
  #     label: Misc | Comics
  #   sortid: 6795ABCE
  #   firstitemmsec: "1205294559301"
  #   htmlUrl: http://xkcd.com/
  #
  class Feed
    include Utilities

    attr_reader :url
    attr_reader :title
    attr_reader :sortid
    attr_reader :id
    attr_reader :client

    alias to_s title

    def initialize(client=Client.new, options)
      @client  = client
      @options = options
      @title   = options['title']
      @url     = options['htmlUrl']
      @sortid  = options['sortid']
      @id      = options['id']
      @tags_   = options['categories']
    end

    def tags
      @tags ||= begin
        @tags_.map { |tag| @client.tag(tag['id']) }
      end
    end

    def to_param
      @id.gsub('/', '_')
    end

    def <=>(other)
      sortid <=> other.sortid
    end

    # List of entries.
    #
    # == Options
    # [limit]         The number of items (default +20+)
    # [order]         The order of items; +:desc+ is recent first, +:asc+ is
    #                 earliest first (default +:desc+)
    # [start_time]    The time (+Time+ object) from which to start getting
    #                 items. Only applicable if +order+ is +:asc+.
    #
    # == Quirks
    # The results are cached. If you want to purge the cache, use {#expire!}.
    #
    # @return [Entries] The entries it contains.
    #
    # @example
    #
    #   @client.feeds[2].entries
    #   @client.feeds[2].entries limit: 10
    #   @client.feeds[2].entries order: :asc, start_time: Time.now-86400
    #
    def entries(options={})
      @entries ||= Entries.fetch @client, "stream/contents/#{escape id}"
    end

    def inspect
      "#<#{self.class.name} \"#{title}\" (#{url})>"
    end

    def expire!
      @entries = nil
    end
  end
end
