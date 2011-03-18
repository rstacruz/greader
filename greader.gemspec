Gem::Specification.new do |s|
  s.name = "greader"
  s.version = "0.0.0"
  s.summary = %{Google Reader API client.}
  s.description = %Q{It reads Google Reader feeds.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/greader.rb"
  s.files = ["lib/greader.rb", "lib/greader/tag.rb", "lib/greader/entry.rb", "lib/greader/client.rb", "lib/greader/utilities.rb", "lib/greader/feed.rb", "lib/greader/entries.rb", "test/client_test.rb", "test/tag_test.rb", "test/helper.rb", "test/fixtures/credentials.yml.example", "test/fixtures/auth.txt", "test/fixtures/tag-list.json", "test/fixtures/credentials.yml", "test/fixtures/subscription-list.json", "test/fixtures/ruby-entries.json", "test/feed_test.rb", "README.md", "Rakefile"]

  s.add_dependency "nokogiri"
  s.add_dependency "rest-client", "~> 1.6"
end
