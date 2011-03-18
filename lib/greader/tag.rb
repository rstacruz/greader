module GReader
  # A tag.
  #
  # == Common usage
  #
  # Getting tags:
  #
  #   tag = @client.tag('TAG_ID')
  #
  # Metadata:
  #
  #   tag.to_s          #=> "Comics"
  #   tag.id            #=> "user/1000/tag/Comics"
  #
  # Collections:
  #
  #   tag.feeds         #=> [#<Feed "xkcd">, #<Feed "Dilbert">, ...]
  #
  class Tag
    attr_reader :id
    attr_reader :sortid
    attr_reader :client

    def initialize(client=Client.new, options)
      @client  = client
      @options = options
      @id      = options['id']
      @sortid  = options['sortid']
    end

    def to_s
      @id.split('/').last
    end

    def to_param
      @id.gsub('/', '_')
    end

    def <=>(other)
      sortid <=> other.sortid
    end

    def feeds
      client.feeds.select { |feed| feed.tags.include?(self) }
    end
  end
end

