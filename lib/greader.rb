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
#   @client.feeds                #=> [#<Feed>, #<Feed>, ...]
#   @client.tags                 #=> [#<Tag>, #<Tag>, ...]
#
#   @client.feed('FEED_ID')
#   @client.tag('TAG_ID')
#
# == Common {Feed} usage
#
#   @client.feeds.each do |feed|
#     p feed.id
#     p feed.title
#     p feed.url
#
#     # A Feed has many entries
#     feed.entries.each do |entry|
#       p entry.title
#       p entry.content
#     end
#   end
#
# == Common {Tag} usage
#
# A {Tag} also has many feeds:
#
#   # Tag
#   @client.tag('TAG_ID').feeds.each { |feed| }
#
# == See
#
# * {Feed}   - A website's feed.
# * {Entry}  - An entry in a feed.
# * {Tag}    - A feed's tag.
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
