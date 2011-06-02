require File.expand_path('../helper', __FILE__)

class FeedTest < Test::Unit::TestCase
  def setup
    @client = GReader.auth credentials
    @feeds  = @client.feeds
    @feed   = @feeds[0]
  end

  test "feeds" do
    assert @feeds.is_a?(Array)
    assert @feeds.size == 3

    assert_equal "Martin Fowler", @feed.title
    assert_equal "http://martinfowler.com/feed.atom", @feed.url
  end

  test "Feed#tags" do
    tag = @feed.tags.first
    assert_equal GReader::Tag, tag.class
    assert_equal "coding", tag.to_s
  end
end
