require 'rest_client'
require 'json'
require 'nokogiri'

# Google Reader API client.
#
# == Common usage
#
# First, log in:
#
#   @client = GReader.auth email: 'test@sinefunc.com', password: 'password'
#
# A {Client} has many {Feed "feeds"} and {Tag "tags"}:
#
#   # Client
#   @client.feeds                #=> [#<Feed>, #<Feed>, ...]
#   @client.tags                 #=> [#<Tag>, #<Tag>, ...]
#   @client.feed('FEED_ID')
#   @client.tag('TAG_ID')
#
# A {Tag} has many feeds:
#
#   # Tag
#   @client.tag(TAG_ID).feeds    # list of feeds
#
# A {Feed} has many {Entry "Entries"}:
#
#   # Feed
#   feed = @client.feeds.first
#   feed.id
#   feed.title
#   feed.url
#
#   # Entry
#   entry = feed.entries.first
#   entry.summary
#
# == See
#
#  * {Feed}   - A website's feed.
#  * {Entry}  - An entry in a feed.
#  * {Tag}    - A feed's tag.
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
