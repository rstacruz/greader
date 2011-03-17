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
    attr_reader :email

    def initialize(options={})
      authenticate options  if options[:email]
    end

    # Authenticates to the Google Reader service.
    # @return [true] on success
    def authenticate(options={})
      @email = options[:email]

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
    rescue RestClient::Forbidden
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
        list.inject({}) { |h, item| feed = Feed.new self, item; h[feed.to_param] = feed; h }
      end
      @feeds.values.sort
    end

    def feed(what=nil)
      feeds && @feeds[what.gsub('/', '_')]
    end

    def tags
      @tags ||= begin
        list = json_get('tag/list')['tags']
        list.inject({}) { |h, item| tag = Tag.new self, item; h[tag.to_param] = tag; h }
      end
      @tags.values.sort
    end

    def tag(what=nil)
      tags && @tags[what.gsub('/', '_')]
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

    def inspect
      "#<#{self.class.name}#{email ? ' '+email.inspect : '' }>"
    end

  protected
  end
end
