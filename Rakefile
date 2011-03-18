$:.push File.expand_path('../test', __FILE__)

task :test do
  Dir['test/**/*_test.rb'].each { |f| load f }
end
