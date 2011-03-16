module GReader
  class Tag
    attr_reader :id
    attr_reader :sortid

    def initialize(client=Client.new, options)
      @client  = client
      @options = options
      @id      = options['id']
      @sortid  = options['sortid']
    end

    def to_s
      @id.split('/').last
    end

    def <=>(other)
      sortid <=> other.sortid
    end

    # def feeds
  end
end

