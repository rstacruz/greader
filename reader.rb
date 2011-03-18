require 'rest_client'
require 'json'
require 'nokogiri'

# Google Reader API client.
#
# http://code.google.com/p/pyrfeed/wiki/GoogleReaderAPI
#
# == Common usage
#
# You will first need to authenticate.
#
#   @client = GReader.auth email: 'test@sinefunc.com', password: 'password'
#
# A client has many feeds and tags.
#
#   # Client (GReader::Client)
#   @client.feeds                #=> [#<Feed>, #<Feed>, ...]
#   @client.tags                 #=> [#<Tag>, #<Tag>, ...]
#
# A feed has many entries. (See GReader::Feed)
#
#   # Feed (GReader::Feed)
#   feed = @client.feeds.first
#   feed.id
#   feed.title
#   feed.url
#   
#   # Entry (GReader::Entry)
#   entry = feed.entries.first
#   entry.content
#
# == See also
#
#   * GReader::Entry - A feed's entry.
#   * GReader::Feed  - A website's feed.
#   * GReader::Tag   - A feed tag.
#
module GReader
  def self.auth(options={})
    client = GReader::Client.new options
    client  if client.logged_in?
  end
end

module GReader
  # A client.
  #
  # == Common usage
  #
  #   # Always returns a client instance, in contrast to `GReader.auth`
  #   # which can return nil.
  #   client = Client.new email: 'test@sinefunc.com', password: 'password'
  #   client.logged_in?
  #
  #   # Caching
  #   @client.tags
  #   @client.tags   # Will be cached
  #   @client.expire!
  #   @client.tags   # Will be re-retrieved
  #
  # == Internal low-level usage
  #
  #   # Making calls
  #   @client.api_get 'subscription/list'   # to /reader/api/0/...
  #   @client.get 'http://foo'              # to arbitrary URL
  #
  class Client
    AUTH_URL   = "https://www.google.com/accounts/ClientLogin"
    API_URL    = "http://www.google.com/reader/api/0/"

    attr_reader :sid
    attr_reader :auth

    def initialize(options={})
      authenticate options  if options[:email]
    end

    # Authenticates to the Google Reader service.
    # @return [true] on success
    def authenticate(options={})
      response = RestClient.post AUTH_URL,
        'service'  => 'reader',
        'continue' => 'http://www.google.com/',
        'Email'    => options[:email],
        'Passwd'   => options[:password],
        'source'   => client_name

      m = /SID=(.*)/i.match(response.to_s)
      @sid = m ? m[1] : nil

      m = /Auth=(.*)/i.match(response.to_s)
      @auth = m ? m[1] : nil

      true
    rescue RestClient::Unauthorized
      false
    end

    def logged_in?
      !@sid.nil? and !@auth.nil?
    end

    def token
      api_get 'token'
    end

    # Expires the cache
    def expire!
      @feeds = nil
      @tags  = nil
    end

    def feeds
      @feeds ||= begin
        list = json_get('subscription/list')['subscriptions']
        list.map { |item| Feed.new self, item }.sort
      end
    end

    def tags
      @tags ||= begin
        list = json_get('tag/list')['tags']
        list.map { |item| Tag.new self, item }.sort
      end
    end

    def unread_count
      json_get 'unread-count', 'all' => 'all'
    end

    def client_name() 'greader.rb/0'; end

    def get(url, options={})
      request :get,
        url, params: options.merge('client' => client_name)
    end

    def post(url, options={})
      request :post,
        url, options.merge('client' => client_name)
    end

    def json_get(url, options={})
      JSON.parse api_get(url, options.merge('output' => 'json'))
    end

    def api_get(url, options={})
      get API_URL+url, options
    end

    def api_post(url, options={})
      post API_URL+url, options
    end

    def request(via, url, options={})
      if logged_in?
        options['Authorization'] = "GoogleLogin auth=#{self.auth}"
        options['cookies'] = { 'SID' => @sid }
      end

      RestClient.send via, url, options
    end
  end

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
    end

    def <=>(other)
      sortid <=> other.sortid
    end

    def entries
      output = @client.get ATOM_URL+id
      doc    = Nokogiri::XML(output)

      @items = doc.css('feed>entry').map do |entry|
        Entry.new self,
          :url       => entry.css('link[rel=alternate]').first['href'],
          :author    => entry.css('author').first.content,
          :summary   => entry.css('summary').first.content,
          :title     => entry.css('title').first.content,
          :published => Date.parse(entry.css('published').first.content),
          :updated   => Date.parse(entry.css('updated').first.content)
      end
    end

    def inspect
      "#<#{self.class.name} \"#{title}\" (#{url})>"
    end
  end

  class Entry
    attr_reader :summary
    attr_reader :author
    attr_reader :title
    attr_reader :published
    attr_reader :updated
    attr_reader :url

    def initialize(feed=Feed.new, options)
      @feed    = feed
      @client  = feed.client

      @author    = options[:author]
      @summary   = options[:summary]
      @title     = options[:title]
      @published = options[:published]
      @updated   = options[:updated]
      @url       = options[:url]
      @options = options
    end

    def inspect
      "#<#{self.class.name} \"#{title}\" (#{url})>"
    end
    # tags (<category>), read?, starred?, etc
    # read! unread!
  end

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

