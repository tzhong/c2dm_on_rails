# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "c2dm_on_rails"
  s.version = "0.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tie Zhong"]
  s.date = "2012-11-11"
  s.description = "This is a fork from popular c2dm_on_rails. C2DM on Rails is a Ruby on Rails gem that allows you to easily add Android Cloud to Device Messaging support to your Rails application. This fork adds a daemon to do the actual push.\n"
  s.email = "zhongtie@yahoo.com"
  s.executables = ["c2dms"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files = [
    ".bundle/config",
    "CHANGELOG",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "Manifest",
    "README.textile",
    "Rakefile",
    "bin/c2dms",
    "c2dm_on_rails.gemspec",
    "lib/c2dm_on_rails.rb",
    "lib/c2dm_on_rails/app/models/c2dm/device.rb",
    "lib/c2dm_on_rails/app/models/c2dm/notification.rb",
    "lib/c2dm_on_rails/c2dm_on_rails.rb",
    "lib/c2dm_on_rails/daemon.rb",
    "lib/c2dm_on_rails/daemon/database_reconnectable.rb",
    "lib/c2dm_on_rails/daemon/delivery_error.rb",
    "lib/c2dm_on_rails/daemon/delivery_handler.rb",
    "lib/c2dm_on_rails/daemon/delivery_handler_pool.rb",
    "lib/c2dm_on_rails/daemon/delivery_queue.rb",
    "lib/c2dm_on_rails/daemon/disconnection_error.rb",
    "lib/c2dm_on_rails/daemon/feeder.rb",
    "lib/c2dm_on_rails/daemon/interruptible_sleep.rb",
    "lib/c2dm_on_rails/daemon/logger.rb",
    "lib/c2dm_on_rails/daemon/pool.rb",
    "lib/c2dm_on_rails/daemon/rapns",
    "lib/c2dm_on_rails/libs/connection.rb",
    "lib/c2dm_on_rails/tasks/c2dm.rake",
    "lib/c2dm_on_rails/version.rb",
    "lib/c2dm_on_rails_tasks.rb",
    "lib/generators/c2dm_migrations_generator.rb",
    "lib/generators/templates/c2dm_migrations/create_c2dm_devices.rb",
    "lib/generators/templates/c2dm_migrations/create_c2dm_notifications.rb"
  ]
  s.homepage = "http://github.com/tzhong/c2dm_on_rails"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Android Cloud to Device Messaging (push notifications) on Rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<configatron>, [">= 0"])
      s.add_runtime_dependency(%q<gdata>, [">= 0"])
      s.add_runtime_dependency(%q<net-http-persistent>, [">= 0"])
      s.add_runtime_dependency(%q<c2dm_on_rails>, [">= 0"])
    else
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<configatron>, [">= 0"])
      s.add_dependency(%q<gdata>, [">= 0"])
      s.add_dependency(%q<net-http-persistent>, [">= 0"])
      s.add_dependency(%q<c2dm_on_rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<configatron>, [">= 0"])
    s.add_dependency(%q<gdata>, [">= 0"])
    s.add_dependency(%q<net-http-persistent>, [">= 0"])
    s.add_dependency(%q<c2dm_on_rails>, [">= 0"])
  end
end

