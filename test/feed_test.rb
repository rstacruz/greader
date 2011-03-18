require File.expand_path('../helper', __FILE__)

class FeedTest < Test::Unit::TestCase
  setup do
    @client = GReader.auth credentials
    @feeds  = @client.feeds
  end

  test "feeds" do
    assert @feeds.is_a?(Array)
    assert @feeds.size == 79

    feed = @feeds[29]
    assert_equal "Badass JavaScript", feed.title
    assert_equal "http://badassjs.com/", feed.url
  end
end
