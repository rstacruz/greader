require 'rest_client'
require 'json'
require 'nokogiri'

# Google Reader API client.
#
# http://code.google.com/p/pyrfeed/wiki/GoogleReaderAPI
#
# == Common usage
#
#   @client = GReader.auth email: 'test@sinefunc.com', password: 'password'
#
#   # Client (GReader::Client)
#   @client.feeds                #=> [#<Feed>, #<Feed>, ...]
#   @client.tags                 #=> [#<Tag>, #<Tag>, ...]
#   @client.feed(FEED_ID)
#   @client.tag(TAG_ID)
#
#   # Tag
#   @client.tag(TAG_ID).feeds    # list of feeds
#
#   # Feed (GReader::Feed)
#   feed = @client.feeds.first
#   feed.id
#   feed.title
#   feed.url
#
#   # Entry (GReader::Entry)
#   entry = feed.entries.first
#   entry.summary
#
module GReader
  PREFIX  = File.expand_path('../greader/', __FILE__)
  VERSION = "0.0.0"

  autoload :Client, "#{PREFIX}/client"
  autoload :Feed,   "#{PREFIX}/feed"
  autoload :Entry,  "#{PREFIX}/entry"
  autoload :Tag,    "#{PREFIX}/tag"

  def self.auth(options={})
    client = GReader::Client.new options
    client  if client.logged_in?
  end

  def version
    VERSION
  end
end
