module GReader
  # Entries list
  #
  # == Common usage
  #
  # This is what's returned by methods like {Feed#entries} and
  # {Tag#entries}.
  #
  #   entries = tag.entries
  #
  # It's a simple array so just use it like so:
  #
  #   entries.each { |entry| puts entry }
  #
  #   entries.size  #=> 20
  #
  # You can also lookup by id:
  #
  #   feeds.entries['ENTRY_ID']
  #
  # But you can have it load more entries:
  #
  #   entries.more
  #   entries.each { |entry| puts entry }
  #
  #   entries.size  #=> 40
  #
  # == Internal usage
  #
  # Pass it an Atom URL.
  #
  #   Entries.fetch @client, @client.atom_url(xxx)
  #
  class Entries < Array
    include Utilities

    attr_reader :continuation  # Continuation token (don't use)
    attr_reader :client

    # Fetch from atom
    def self.fetch(client, url, options={})
      doc      = client.json_get(url, to_params(options))
      contents = doc['items'].map do |node|
        Entry.new client, Entry.parse_json(node)
      end

      new contents, client, options.merge(:url => url)
    end

    def initialize(contents, client, options={})
      super contents
      @continuation = options[:continuation]
      @url          = options[:url]
      @client       = client
    end

    def more
      # self + fetch(@client, @url, :from => @continuation)
    end

    def +(other)
      #
    end

    # Lookup
    def [](id)
      indices[slug(id)]
    end

  protected
    def indices
      @indices ||= entries.inject({}) { |h, entry| h[slug(entry.id)] = entry; h }
    end

    # Converts normal options to Google's equivalents.
    # See {Feed#entries}.
    def self.to_params(options={})
      params = Hash.new
      params[:n]  = options[:limit]  if options[:limit]
      params[:c]  = options[:from]   if options[:from]  # Continuation
      params[:r]  = 'o'              if options[:order] == :asc
      params[:ot] = options[:start_time].to_i  if options[:start_time]
      params
    end
  end
end

