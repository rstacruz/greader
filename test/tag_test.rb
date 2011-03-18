require File.expand_path('../helper', __FILE__)

class TagTest < Test::Unit::TestCase
  setup do
    @client = GReader.auth credentials
    @tags   = @client.tags
  end

  test "tags" do
    assert_equal 24, @tags.size
    assert_equal "Dev | Ruby", @tags[4].to_s
  end

  describe "entries" do
    setup do
      @tag     = @tags[4]
      @entries = @tag.entries
      @entry   = @entries.first
    end

    test "Entries" do
      assert @entries.is_a?(GReader::Entries)
    end

    test "tag entries" do
      assert @entry.is_a?(GReader::Entry)

      assert_equal "Github reviews as a way to improve code quality?", @entry.title
      assert_equal @entry.title, @entry.to_s
      assert_equal "(author unknown)", @entry.author
    end

    test "Entry#feed" do
      assert @entry.feed.is_a?(GReader::Feed)
      assert_equal @entry.feed, @client.feed(@entry.feed.id)
    end
  end
end
