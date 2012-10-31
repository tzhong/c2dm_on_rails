require 'gdata'
require 'net/https'
require 'net/http/persistent'
require 'uri'

module C2dm
	module Connection

		class << self
			def persistent_post(url_string, data, headers)
				url=URI.parse url_string
				http = Net::HTTP::Persistent::SSLReuse.new url.host, url.port
				http.use_ssl = true
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
				resp, dat = http.post(url.path, data, headers)

				return {:code => resp.code.to_i, :message => dat} 
			end

			def send_c2dm_notification(noty, token)
				headers = { "Content-Type" => "application/x-www-form-urlencoded", 
					"Authorization" => "GoogleLogin auth=#{token}" }

				message_data = noty.data.map{|k, v| "&data.#{k}=#{URI.escape( (v.class == Hash) ? ActiveSupport::JSON.encode(v) : v)}"}.reduce{|k, v| k + v}
				data = "registration_id=#{noty.device.registration_id}&collapse_key=#{noty.collapse_key}#{message_data}"

				data = data + "&delay_while_idle" if noty.delay_while_idle

				url_string = configatron.c2dm.api_url
				url=URI.parse url_string
				persistent_post(url_string, data, headers)
			end

			def open
				client_login_handler = GData::Auth::ClientLogin.new('ac2dm', :account_type => 'GOOGLE')
				token = client_login_handler.get_token(configatron.c2dm.username,
													   configatron.c2dm.password,
													   configatron.c2dm.app_name)

				yield token
			end

			def send_gcm_notification(notification)
				api_key = configatron.gcm_on_rails.api_key
				format = configatron.gcm_on_rails.delivery_format

				if format == 'json'
					headers = {"Content-Type" => "application/json",
						"Authorization" => "key=#{api_key}"}

					data = notification.data.merge({:collapse_key => notification.collapse_key}) unless notification.collapse_key.nil?
					data = data.merge({:delay_while_idle => notification.delay_while_idle}) unless notification.delay_while_idle.nil?
					data = data.merge({:registration_ids => [notification.device.registration_id]})
					data = data.to_json
				else #plain text format
					headers = {"Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
						"Authorization" => "key=#{api_key}"}

					post_data = notification.data[:data].map{|k, v| "&data.#{k}=#{URI.escape(v)}".reduce{|k, v| k + v}}[0]
					extra_data = "registration_id=#{notification.data[:registration_ids][0]}"
					extra_data = "#{extra_data}&collapse_key=#{notification.collapse_key}" unless notification.collapse_key.nil?
					extra_data = "#{extra_data}&delay_while_idle=1" if notification.delay_while_idle
					data = "#{extra_data}#{post_data}"
				end

				url_string = configatron.gcm_on_rails.api_url
				persistent_post(url_string, data, headers)
			end
		end
	end # Connection
end # C2dm
