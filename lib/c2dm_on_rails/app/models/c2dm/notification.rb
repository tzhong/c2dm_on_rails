require 'net/http'
require 'uri'

# Represents the message you wish to send. 
# An C2dm::Notification belongs to an C2dm::Device.
# 
# Example:
#   c2dm = C2dm::Notification.new
#   c2dm.key = "value"
#   c2dm.device = APN::Device.find(1)
#   c2dm.save
# 
# To deliver call the following method:
#   C2dm::Notification.send_notifications
# 
# As each C2dm::Notification is sent the <tt>sent_at</tt> column will be timestamped,
# so as to not be sent again.
module C2dm
	class Notification < ActiveRecord::Base

		self.table_name = "c2dm_notifications"

		# All instance methods
		include ::ActionView::Helpers::TextHelper
		# All class methods
		extend ::ActionView::Helpers::TextHelper
		serialize :data

		belongs_to :device, :class_name => 'C2dm::Device'

		class << self

			def ready_for_delivery
				C2dm::Notification.all(:conditions => {:sent_at => nil}, :joins => :device, :readonly => false)
			end

			# Opens a connection to the Google C2dm server and attempts to batch deliver
			# an Array of notifications.
			# 
			# This method expects an Array of C2dm::Notifications. If no parameter is passed
			# in then it will use the following:
			#   C2dm::Notification.all(:conditions => {:sent_at => nil})
			# 
			# As each C2dm::Notification is sent the <tt>sent_at</tt> column will be timestamped,
			# so as to not be sent again.
			# 
			# This can be run from the following Rake task:
			#   $ rake c2dm:notifications:deliver
			def send_notification(noty)
				if (noty.protocol == "c2dm")
					send_a2pn(noty)
				elsif (noty.protocol == "acm")
					send_acm(noty)
				end
			end

			def send_acm(noty)
				resp = C2dm::Connection.send_acm_notification(noty)
			end

			def send_a2pn(noty)
				token = init_auth_token

				puts "sending notification #{noty.id} to device #{noty.device.registration_id}"
				response = C2dm::Connection.send_c2dm_notification(noty, token)
				puts "response: #{response[:code]}; #{response.inspect}"

				if response[:code] == 200
					@retrying = false

					case response[:message]
					when "Error=QuotaExceeded"
						raise C2dm::Errors::QuotaExceeded.new(response[:message])

					when "Error=DeviceQuotaExceeded"
						ex = C2dm::Errors::DeviceQuotaExceeded.new(response[:message])
						logger.warn(ex.message)

					when "Error=InvalidRegistration"
						ex = C2dm::Errors::InvalidRegistration.new(response[:message])
						logger.warn("#{ex.message}, destroying c2dm_device with id #{noty.device.id}")
						noty.device.destroy

					when "Error=NotRegistered"
						ex = C2dm::Errors::NotRegistered.new(response[:message])
						logger.warn("#{ex.message}, destroying c2dm_device with id #{noty.device.id}")
						noty.device.destroy

					when "Error=MessageTooBig"
						ex = C2dm::Errors::MessageTooBig.new(response[:message])
						logger.warn(ex.message)

					when "Error=MissingCollapseKey"
						ex = C2dm::Errors::MissingCollapseKey.new(response[:message])
						logger.warn(ex.message)

					else
						noty.sent_at = Time.now
						noty.save!
					end

				elsif response[:code] == 503
					raise C2dm::Errors:ServiceUnavailable.new(response[:message])

				elsif response[:code] == 401
					# To prevent possible infinite loop
					raise C2dm::Errors::InvalidAuthToken.new(response[:message]) if @retrying

					C2dm::Connection.open do |token|
						@auth_token = token
						@retrying = true
						return send_notification noty
					end
				else
				end
			end

			# Send all pending notifications
			def send_notifications(notifications = C2dm::Notification.all(:conditions => {:sent_at => nil}, :joins => :device, :readonly => false))
				unless notifications.nil? || notifications.empty?

					notifications.each do |noty|
						send_notification(noty)
					end
				end
			end

			def init_auth_token
				if @auth_token.blank?
					C2dm::Connection.open do |token|
						C2dm::Daemon.logger.info("Refreshed c2dm token")
						@auth_token = token
					end
				end

				@auth_token
			end

		end # class << self

	end # C2dm::Notification
end
