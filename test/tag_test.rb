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
      @tag = @tags[4]
    end

    test "tag entries" do
      @entries = @tag.entries
    end
  end
end
