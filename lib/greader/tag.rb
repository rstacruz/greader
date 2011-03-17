module GReader
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
      @id
    end

    def <=>(other)
      sortid <=> other.sortid
    end

    def feeds
      client.feeds.select { |feed| feed.tags.include?(self) }
    end
  end
end

