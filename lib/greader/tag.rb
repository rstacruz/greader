module GReader
  # A tag.
  #
  # == Common usage
  #
  # Getting tags:
  #
  #   tag = @client.tag('TAG_ID')   # see Tag#id below
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
    include Utilities

    # The ID. Also used for {Client#tag}.
    # @return [string]
    attr_reader :id

    # A sortable field.
    # @return [string]
    attr_reader :sortid

    # A link to {Client}.
    # @return [Client]
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

    # Returns a list of feeds.
    # @return [Feed[]]
    def feeds
      client.feeds.select { |feed| feed.tags.include?(self) }
    end

    # (see Feed#entries)
    def entries(options={})
      @entries ||= Entries.fetch @client, Client.atom_url(id)
    end

    # Expires the cache.
    # @return nil
    def expire!
      @entries = nil
    end
  end
end

