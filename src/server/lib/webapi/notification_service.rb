require 'rubygems'
require 'apns'
require 'yaml'

module Meet4Xmas
  module WebAPI
    module NotificationService
      def self.configure_services
        self.configure_apns
      end

      def self.load_config
        @config ||= YAML.load_file(File.join File.dirname(__FILE__) , '..', '..', 'config', 'push.yml')
      end

      def self.configure_apns
        self.load_config

        pem_path = [File.dirname(__FILE__), '..', '..', 'config'] + @config['APNS']['pem']
        APNS.pem = File.join pem_path
        APNS.pass = @config['APNS']['pass']
      end

      ##
      # possible options for iOS:
      #  - :badge (number)
      #  - :sound (string)
      #  - other keys possible. Those are send and later processed by your iApp (at least thats what I know)
      def self.send_push_notification(notification_service, message, options = {})
        case notification_service.service_type
        when NotificationServiceType::APNS
          apns_opts = {}
          apns_opts[:alert] = message
          #apns_opts[:badge] = options.delete :badge
          #apns_opts[:sound] = options.delete :sound
          #apns_opts[:other] = options unless options.empty?
          puts "sending APNS notification to '#{notification_service.device_id}' with #{apns_opts}"
          APNS.send_notification(notification_service.device_id, apns_opts)
        else
          raise "can't send notification to device type '#{notification_service.device_type}'"
        end
      end
    end
  end
end
