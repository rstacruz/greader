Gem::Specification.new do |s|
  s.name = "greader"
  s.version = "0.0.1"
  s.summary = %{Google Reader API client.}
  s.description = %Q{It reads Google Reader feeds.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/greader.rb"
  s.files = ["lib/greader/client.rb", "lib/greader/entries.rb", "lib/greader/entry.rb", "lib/greader/feed.rb", "lib/greader/tag.rb", "lib/greader/utilities.rb", "lib/greader.rb", "test/client_test.rb", "test/feed_test.rb", "test/fixtures/auth.txt", "test/fixtures/credentials.yml", "test/fixtures/credentials.yml.example", "test/fixtures/ruby-entries.json", "test/fixtures/subscription-list.json", "test/fixtures/tag-list.json", "test/helper.rb", "test/tag_test.rb", "README.md", "Rakefile"]

  s.add_dependency "nokogiri"
  s.add_dependency "rest-client", "~> 1.6"
end
