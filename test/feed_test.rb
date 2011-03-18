require File.expand_path('../helper', __FILE__)

class FeedTest < Test::Unit::TestCase
  setup do
    @client = GReader.auth credentials
    @feeds  = @client.feeds
    @feed   = @feeds[29]
  end

  test "feeds" do
    assert @feeds.is_a?(Array)
    assert @feeds.size == 79

    assert_equal "Badass JavaScript", @feed.title
    assert_equal "http://badassjs.com/", @feed.url
  end

  test "Feed#tags" do
    tag = @feed.tags.first
    assert tag.is_a?(GReader::Tag)
    assert_equal "Dev | JavaScript", tag.to_s
  end
end
