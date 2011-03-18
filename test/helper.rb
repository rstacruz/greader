ENV['RESTCLIENT_LOG'] = 'stdout'  if ENV['REAL']

$:.push File.expand_path('../../lib', __FILE__)

begin
  require 'contest'
  require 'fakeweb'
  require 'yaml'
rescue LoadError => e
  puts "Load error (#{e.message})."
  puts "Try: gem install contest fakeweb"
  exit
end

require 'greader'

module TestHelpers
  extend self

  def fixture_file(*a)
    File.join File.expand_path('../fixtures', __FILE__), *a
  end

  def fixture(*a)
    File.open(fixture_file(*a)) { |f| f.read }
  end

  def fixture?(*a)
    File.exists? fixture_file(*a)
  end

  def credentials
    if real?
      YAML::load fixture('credentials.yml')
    else
      { :email => 'christian@mcnamara-troy.com', :password => 'yoplait' }
    end
  end

  def real?
    ENV['REAL'] && fixture('credentials.yml')
  end

  def fake(*a)
    FakeWeb.register_uri(*a)  unless real?
  end
end

class GReader::Client
  def client_name() 'greader.rb-test'; end
end

class Test::Unit::TestCase
  include TestHelpers

  setup do
    fake :post, "https://www.google.com/accounts/ClientLogin", :body => fixture('auth.txt')
    fake :get, "http://www.google.com/reader/api/0/subscription/list?output=json&client=greader.rb-test", :body => fixture('subscription-list.json')
    fake :get, "http://www.google.com/reader/api/0/tag/list?output=json&client=greader.rb-test", :body => fixture('tag-list.json')
    fake :get, "http://www.google.com/reader/atom/user%2F05185BEEF%2Flabel%2FDev%20%7C%20Ruby?client=greader.rb-test", :body => fixture('ruby-entries.xml')
  end
end

if ENV['REAL']
  if TestHelpers.real?
    puts "*** Running in real mode."
  else
    puts "*** You need test/fixtures/credentials.yml to run in REAL mode."
    exit
  end
end
