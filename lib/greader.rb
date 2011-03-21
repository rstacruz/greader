require 'json'
require 'rest_client'  unless defined?(RestClient)
require 'nokogiri'     unless defined?(Nokogiri)

require File.expand_path('../greader/nokogiri/normalizer', __FILE__)

# Google Reader API client.
#
# == Common usage
#
# First, log in (returns a {Client} or `nil`):
#
#   @client = GReader.auth email: 'test@sinefunc.com', password: 'password'
#
# == Common {Client} usage
#
# A {Client} has many {Feed Feeds} and {Tag Tags}:
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
# == Other
#
#   GReader.version            #=> "0.0.0"
#
# == See also
#
# {Feed}::   A website's feed.
# {Entry}::  An entry in a feed.
# {Tag}::    A feed's tag.
#
module GReader
  PREFIX  = File.expand_path('../greader/', __FILE__)
  VERSION = "0.0.0"

  autoload :Client,    "#{PREFIX}/client"
  autoload :Entry,     "#{PREFIX}/entry"
  autoload :Entries,   "#{PREFIX}/entries"
  autoload :Feed,      "#{PREFIX}/feed"
  autoload :Tag,       "#{PREFIX}/tag"
  autoload :Utilities, "#{PREFIX}/utilities"

  def self.auth(options={})
    client = GReader::Client.new options
    client  if client.logged_in?
  end

  def self.version
    VERSION
  end

  Error      = Class.new(StandardError)
  ParseError = Class.new(Error)
end
