module GReader
  # A client.
  #
  # == Common usage
  #
  # Greader.auth is the preferred way.
  #
  #   @client = GReader.auth email: 'test@sinefunc.com', password: 'password'
  #   @client.nil?  # nil if logging in fails
  #
  # You can also use it like so:
  #
  #   client = Client.new email: 'test@sinefunc.com', password: 'password'
  #   client.logged_in?
  #
  # See GReader for more common usage of the Client class.
  #
  # == Caching and expiration
  #
  #   # Caching
  #   @client.tags
  #   @client.tags      # Will be retrieved from cache
  #   @client.expire!
  #   @client.tags      # Will be re-retrieved online
  #
  # == Internal low-level usage
  #
  #   # Making calls
  #   @client.api_get 'subscription/list'   # to /reader/api/0/...
  #   @client.get 'http://foo'              # to arbitrary URL
  #
  class Client
    include Utilities
    
    AUTH_URL   = "https://www.google.com/accounts/ClientLogin"
    API_URL    = "http://www.google.com/reader/api/0/"

    attr_reader :auth
    attr_reader :email

    # Constructor.
    #
    # The constructor can be called without args, but you won't be able to
    # do anything that requires authentication (which is pretty much 
    # everything).
    #
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

      m = /Auth=(.*)/i.match(response.to_s)
      @auth = m ? m[1] : nil

      true
    rescue RestClient::Forbidden
      false
    end

    def logged_in?
      !@auth.nil?
    end

    def token
      @token ||= api_get 'token'
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
      feeds && @feeds[what.to_s.gsub('/', '_')]
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
      options['Authorization'] = "GoogleLogin auth=#{self.auth}"  if logged_in?

      RestClient.send via, url, options
    end

    def inspect
      "#<#{self.class.name}#{email ? ' '+email.inspect : '' }>"
    end
  end
end
