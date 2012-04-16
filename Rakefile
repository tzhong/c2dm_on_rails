require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

require 'jeweler'

require 'lib/c2dm_on_rails/version'

Jeweler::Tasks.new do |gem|
  gem.name = "c2dm_on_rails"
  gem.summary = "Android Cloud to Device Messaging (push notifications) on Rails"
  gem.description = %q{This is a fork from popular c2dm_on_rails. C2DM on Rails is a Ruby on Rails gem that allows you to easily add Android Cloud to Device Messaging support to your Rails application. This fork adds a daemon to do the actual push.
}
  gem.executables = "c2dms"
  gem.version = C2dm::VERSION

  gem.email = "zhongtie@yahoo.com"
  gem.homepage = "http://github.com/tzhong/c2dm_on_rails"
  gem.authors = ["Tie Zhong"]
end
task :default => :spec
