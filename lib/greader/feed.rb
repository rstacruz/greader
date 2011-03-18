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
  # == Sample output from Google
  #
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
          Entry.new self, parse_entry(entry)
        end
      end
    end

    def inspect
      "#<#{self.class.name} \"#{title}\" (#{url})>"
    end

    def expire!
      @entries = nil
    end

  protected
    # Returns a hash from an entry XML node.
    def parse_entry(entry)
      { :url       => entry.css('link[rel=alternate]').first['href'],
        :author    => entry.css('author').first.content,
        :content   => entry.css('content, summary').first.content,
        :title     => entry.css('title').first.content,
        :published => Date.parse(entry.css('published').first.content),
        :updated   => Date.parse(entry.css('updated').first.content)
      }
    rescue NoMethodError
      puts "*"*80
      puts entry.to_s
      Hash.new
    end
  end
end
