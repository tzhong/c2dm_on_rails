class PGError < StandardError; end if !defined?(PGError)
class Mysql; class Error < StandardError; end; end if !defined?(Mysql)
module Mysql2; class Error < StandardError; end; end if !defined?(Mysql2)

module C2dm
	module Daemon
		module DatabaseReconnectable
			ADAPTER_ERRORS = [ActiveRecord::StatementInvalid, PGError, Mysql::Error, Mysql2::Error] unless const_defined?(:ADAPTER_ERRORS)

			def with_database_reconnect_and_retry
				begin
					yield
				rescue *ADAPTER_ERRORS => e
					C2dm::Daemon.logger.error(e)
					database_connection_lost
					retry
				end
			end

			def database_connection_lost
				C2dm::Daemon.logger.warn("[#{name}] Lost connection to database, reconnecting...")
				attempts = 0
				loop do
					begin
						C2dm::Daemon.logger.warn("[#{name}] Attempt #{attempts += 1}")
						reconnect_database
						check_database_is_connected
						break
					rescue *ADAPTER_ERRORS => e
						C2dm::Daemon.logger.error(e, :airbrake_notify => false)
						sleep_to_avoid_thrashing
					end
				end
				C2dm::Daemon.logger.warn("[#{name}] Database reconnected")
			end

			def reconnect_database
				ActiveRecord::Base.clear_all_connections!
				ActiveRecord::Base.establish_connection
			end

			def check_database_is_connected
				# Simply asking the adapter for the connection state is not sufficient.
				C2dm::Notification.count
			end

			def sleep_to_avoid_thrashing
				sleep 2
			end
		end
	end
end