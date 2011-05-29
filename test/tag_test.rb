require File.expand_path('../helper', __FILE__)

class TagTest < Test::Unit::TestCase
  def setup
    @client = GReader.auth credentials
    @tags   = @client.tags
    @tag    = @tags[0]
  end

  test "Client#tags" do
    assert_equal 7, @tags.size
  end

  test "Tag" do
    assert_equal "coding", @tag.to_s
  end

  test "Tag#feeds" do
    @feeds = @tag.feeds

    control = ["Martin Fowler", "Ruby5", "RubyFlow"]
    assert_equal control, @feeds.map(&:to_s)
  end

  describe "Entries" do
    setup do
      @entries = @tag.entries
      @entry   = @entries.first
    end

    test "is_a Entries" do
      assert @entries.is_a?(GReader::Entries)
    end

    test "tag entries" do
      assert @entry.is_a?(GReader::Entry)

      assert_equal @entry.title, @entry.to_s
    end

    test "Entry#feed" do
      assert @entry.feed.is_a?(GReader::Feed)
      assert_equal @entry.feed, @client.feed(@entry.feed.id)
    end
  end
end
