module C2dm
	module Daemon
		class Feeder
			extend DatabaseReconnectable
			extend InterruptibleSleep

			def self.name
				"Feeder"
			end

			def self.start(foreground)
				reconnect_database unless foreground

				loop do
					break if @stop
					enqueue_notifications
					#
					# TODO
					# Hard-code the poll interval to 2 seconds
					interruptible_sleep 2
				end
			end

			def self.stop
				@stop = true
				interrupt_sleep
			end

			protected

			def self.enqueue_notifications
				begin
					with_database_reconnect_and_retry do
						# Don't enqueue unless the previous list has all been processed
						# to avoid excessive enqueuing and queue overflow.
						#
						if C2dm::Daemon.delivery_queue.notifications_processed?
							C2dm::Notification.ready_for_delivery.each do |notification|
								C2dm::Daemon.delivery_queue.push(notification)
							end
						end
					end
				rescue StandardError => e
					C2dm::Daemon.logger.error(e)
				end
			end
		end
	end
end
