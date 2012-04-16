module C2dm
	module Daemon
		class Logger
			def initialize(options)
				@options = options
				log_path = File.join(Rails.root, 'log', 'c2dm.log')
				@logger = ActiveSupport::BufferedLogger.new(log_path, Rails.logger.level)
				@logger.auto_flushing = Rails.logger.respond_to?(:auto_flushing) ? Rails.logger.auto_flushing : true
			end

			def info(msg)
				log(:info, msg)
			end

			def error(msg, options = {})
				log(:error, msg, 'ERROR')
			end

			def warn(msg)
				log(:warn, msg, 'WARNING')
			end

			private

			def log(where, msg, prefix = nil)
				if msg.is_a?(Exception)
					msg = "#{msg.class.name}, #{msg.message}"
				end

				formatted_msg = "[#{Time.now.to_s(:db)}] "
				formatted_msg << "[#{prefix}] " if prefix
				formatted_msg << msg
				puts formatted_msg if @options[:foreground]
				@logger.send(where, formatted_msg)
			end

		end
	end
end
