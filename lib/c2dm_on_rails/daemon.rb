require 'thread'
require 'socket'
require 'pathname'

require 'c2dm_on_rails/daemon/interruptible_sleep'
require 'c2dm_on_rails/daemon/delivery_error'
require 'c2dm_on_rails/daemon/disconnection_error'
require 'c2dm_on_rails/daemon/pool'
require 'c2dm_on_rails/daemon/database_reconnectable'
require 'c2dm_on_rails/daemon/delivery_queue'
require 'c2dm_on_rails/daemon/delivery_handler'
require 'c2dm_on_rails/daemon/delivery_handler_pool'
require 'c2dm_on_rails/daemon/feeder'
require 'c2dm_on_rails/daemon/logger'

module C2dm
	module Daemon
		class << self
			attr_accessor :logger, :delivery_queue, :delivery_handler_pool, :foreground, :auth_token
			alias_method  :foreground?, :foreground
		end

		def self.start(environment, foreground)
			@foreground = foreground

			# Handlers for shutdown signals
			setup_signal_hooks

			self.logger = Logger.new(:foreground => foreground)

			self.delivery_queue = DeliveryQueue.new

			daemonize unless foreground?

			# Delegate the push task to the DeliveryHandler objects
			# TODO: Hard-code the default number of connections to 3 for now.
			self.delivery_handler_pool = DeliveryHandlerPool.new(1)
			delivery_handler_pool.populate

			logger.info("Updating auth token ...")
			C2dm::Connection.open{|t| @auth_token = t}
			logger.info("Token updated: #{@auth_token}")

			logger.info('Ready')

			# EnQueue the notifications for delivery
			Feeder.start(foreground?)
		end

		protected

		def self.setup_signal_hooks
			@shutting_down = false

			['SIGINT', 'SIGTERM'].each do |signal|
				Signal.trap(signal) do
					handle_shutdown_signal
				end
			end
		end

		def self.handle_shutdown_signal
			exit 1 if @shutting_down
			@shutting_down = true
			shutdown
		end

		def self.shutdown
			puts "\nShutting down..."
			C2dm::Daemon::Feeder.stop
			C2dm::Daemon.delivery_handler_pool.drain if C2dm::Daemon.delivery_handler_pool
		end

		def self.daemonize
			exit if pid = fork
			Process.setsid
			exit if pid = fork

			# TODO: why this?
			Dir.chdir '/'
			File.umask 0000

			STDIN.reopen '/dev/null'
			STDOUT.reopen '/dev/null', 'a'
			STDERR.reopen STDOUT
		end

	end
end
