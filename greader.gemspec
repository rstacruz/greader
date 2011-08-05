require "./lib/greader/version"
Gem::Specification.new do |s|
  s.name = "greader"
  s.version = GReader.version.to_s
  s.summary = "Google Reader API client."
  s.description = "It reads Google Reader feeds."
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/greader.rb"
  s.files = Dir["{lib,test}/**/*", "*.md", "Rakefile"].reject { |f| File.directory?(f) }

  s.add_dependency "nokogiri", "~> 1.4.4"
  s.add_dependency "rest-client", "~> 1.6"
end

# $ gem build *.gemspec
# $ gem push *.gem
