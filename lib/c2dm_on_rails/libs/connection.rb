require 'gdata'
require 'net/https'
require 'uri'

module C2dm
	module Connection

		class << self
			def send_notification(noty, token)
				headers = { "Content-Type" => "application/x-www-form-urlencoded", 
					"Authorization" => "GoogleLogin auth=#{token}" }

				message_data = noty.data.map{|k, v| "&data.#{k}=#{URI.escape( (v.class == Hash) ? ActiveSupport::JSON.encode(v) : v)}"}.reduce{|k, v| k + v}
				data = "registration_id=#{noty.device.registration_id}&collapse_key=#{noty.collapse_key}#{message_data}"

				data = data + "&delay_while_idle" if noty.delay_while_idle

				url_string = configatron.c2dm.api_url
				url=URI.parse url_string
				http = Net::HTTP.new(url.host, url.port)
				http.use_ssl = true
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE

				resp, dat = http.post(url.path, data, headers)

				return {:code => resp.code.to_i, :message => dat} 

				# TODO
				# Performance improvement by using HTTP keep-alive

				#  net/http uses a little known behavior where by default an 
				#  "Connection: close" header is appended to each request,
				#  except when you're using the block form
				#  require 'net/http/pipeline'
				#  Net::HTTP.start "localhost", 9000 do |http|
				#  htt.pipeline = true
					#  reqs = []
					#  reqs << http.get('/a.html')
					#  reqs << http.get('/b.html')
				#  end

			end

			def open
				client_login_handler = GData::Auth::ClientLogin.new('ac2dm', :account_type => 'GOOGLE')
				token = client_login_handler.get_token(configatron.c2dm.username,
													   configatron.c2dm.password,
													   configatron.c2dm.app_name)

				yield token
			end
		end
	end # Connection
end # C2dm
