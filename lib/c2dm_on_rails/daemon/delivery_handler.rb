module C2dm
	module Daemon
		class DeliveryHandler
			include DatabaseReconnectable

			C2DM_STOP = 0x666 unless const_defined?(:C2DM_STOP)

			attr_reader :name

			def initialize(i)
			end

			def start
				Thread.new do
					loop do
						break if @stop
						handle_next_notification
					end
				end
			end

			def stop
				@stop = true
				C2dm::Daemon.delivery_queue.push(C2DM_STOP)
			end

			protected

			def deliver(notification)
				begin
					C2dm::Notification.send_notification(notification)
					C2dm::Daemon.logger.info("Notification #{notification.id} delivered to #{notification.device.registration_id}")
				rescue Exception => error
					handle_delivery_error(notification, error)
					raise
				end
			end

			def handle_delivery_error(notification, error)
				#  with_database_reconnect_and_retry do
				#  	notification.error = error.description
				#  	notification.save!(:validate => false)
				#  end
			end

			def handle_next_notification
				notification = C2dm::Daemon.delivery_queue.pop

				if notification == C2DM_STOP
					#TODO: what for c2dm?
					#  @connection.close
					return
				end

				begin
					deliver(notification)
				rescue StandardError => e
					C2dm::Daemon.logger.error(e)
				ensure
					C2dm::Daemon.delivery_queue.notification_processed
				end
			end
		end
	end
end
