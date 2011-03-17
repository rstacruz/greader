module GReader
  # A feed.
  #
  # == Common usage
  #
  #   feed = client.feed('feed_id_here')
  #   feed.title
  #   feed.entries
  #
  # == Sample output from Google
  #
  #   id: feed/http://xkcd.com/rss.xml
  #   title: xkcd.com
  #   categories: 
  #   - id: user/05185502537486227907/label/Misc | Comics
  #     label: Misc | Comics
  #   sortid: 6795ABCE
  #   firstitemmsec: "1205294559301"
  #   htmlUrl: http://xkcd.com/

  class Feed
    ATOM_URL   = "http://www.google.com/reader/atom/"

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

    def entries
      @entries ||= begin
        output = @client.get ATOM_URL+id
        doc    = Nokogiri::XML(output)

        doc.css('feed>entry').map do |entry|
          Entry.new self,
            :url       => entry.css('link[rel=alternate]').first['href'],
            :author    => entry.css('author').first.content,
            :summary   => entry.css('summary').first.content,
            :title     => entry.css('title').first.content,
            :published => Date.parse(entry.css('published').first.content),
            :updated   => Date.parse(entry.css('updated').first.content)
        end
      end
    end

    def inspect
      "#<#{self.class.name} \"#{title}\" (#{url})>"
    end

    def expire!
      @entries = nil
    end
  end
end
