module GReader
  # A feed entry.
  #
  # == Common usage
  #
  # Getting entries:
  #
  #   feed.entries.each { |entry| }
  #   tag.entries.each { |entry| }
  #   feed.entries['ENTRY_ID']  # See Entry#id below
  #
  # Common metadata:
  #
  #   entry.title           #=> "On pride and prejudice" (or #to_s)
  #   entry.content         #=> "<p>There was a time where..."
  #   entry.summary         #=> "There was a time where..." (no HTML)
  #   entry.image_url       # URL of the first image
  #
  # More metadata:
  #
  #   entry.author          #=> "Rico Sta. Cruz"
  #   entry.updated         #=> #<Date>
  #   entry.published       #=> #<Date>
  #   entry.url             #=> "http://ricostacruz.com/on-pride-and-prejudice.html"
  #   entry.id              #=> "reader_item_128cb290d31352d9"
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
    include Utilities

    attr_reader :content
    attr_reader :author
    attr_reader :title
    attr_reader :published
    attr_reader :updated
    attr_reader :url
    attr_reader :id

    attr_reader :feed
    attr_reader :client

    alias to_s title

    # Constructor.
    # Can be called with an options hash or a Nokogiri XML node.
    def initialize(client=Client.new, options)
      @client  = client

      @feed      = client.feed(options[:feed])
      @author    = options[:author]
      @content   = GReader.process_html(options[:content])
      @title     = options[:title]
      @published = options[:published]
      @updated   = options[:updated]
      @url       = options[:url]
      @id        = options[:id]
      @options = options
    end

    def inspect
      "#<#{self.class.name} \"#{title}\" (#{url})>"
    end

    def to_param
      slug @id
    end

    # Returns a Nokogiri document.
    def doc
      @doc ||= Nokogiri.HTML(content)
    end

    # Returns a short summary
    # @return [string]
    # @return [nil]
    def summary
      doc = self.doc.dup

      # Remove images and empty paragraphs
      doc.xpath('*//img').each { |tag| tag.remove }
      doc.xpath('*//*[normalize-space(.)=""]').each { |tag| tag.remove }

      # The first block
      el = doc.xpath('//body/p | //body/div').first || doc.xpath('//body').first
      el and el.text
    end

    # Returns the {#content} without HTML tags
    def bare_content
      strip_tags(content)
    end

    # Returns the URL of the first image
    # @return [string]
    # @return [nil]
    def image_url
      url = raw_image_url and begin
        return nil  if url.include?('feedburner.com') # "Share on Facebook"
        url
      end
    end

    def raw_image_url
      img = doc.xpath('*//img').first and img['src']
    end

    def image?
      ! image_url.nil?
    end

    # Converts a Noko XML node into a simpler Hash.
    def self.parse_json(doc)
      summary = (doc['content'] || doc['summary'])
      summary = summary['content']  if summary.is_a?(Hash)

      { :url       => doc['alternate'].first['href'],
        :author    => doc['author'],
        :content   => summary,
        :title     => doc['title'],
        :published => Time.new(doc['published']),
        :updated   => Time.new(doc['updated']),
        :feed      => doc['origin']['streamId'],
        :id        => doc['id']
        # Also available: comments [], annotations [], enclosure 
        # [{href,type,length}]
      }
    rescue NoMethodError
      raise ParseError.new("Malformed entries", doc)
    end

    # tags (<category>), read?, starred?, etc
    # read! unread!
  end
end
