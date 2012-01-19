require 'rubygems'
require 'yaml'
require 'apns'
require 'wpns'

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
        return if @apns_configured
        self.load_config
        @apns_config = @config['APNS']

        # override options for host and port
        APNS.host = @apns_config['host'] if @apns_config['host']
        APNS.port = @apns_config['port'] if @apns_config['port']

        # certificate options
        pem_path = [File.dirname(__FILE__), '..', '..', 'config'] + @apns_config['pem']
        APNS.pem = File.join pem_path
        APNS.pass = @apns_config['pass']

        @apns_configured = true
      end

      ##
      # possible options for iOS:
      #  - :badge (number)
      #  - :sound (string)
      #  - other keys possible. Those are send and later processed by your iApp (at least thats what I know)
      def self.send_notification(notification_service, message, options = {})
        case notification_service.service_type
        when Meet4Xmas::Persistence::NotificationServiceType::APNS
          ios_options = {}
          ios_options[:alert] = message
          #ios_options[:badge] = options.delete :badge
          #ios_options[:sound] = options.delete :sound
          #ios_options[:other] = options unless options.empty?
          self.send_apns_notification notification_service.device_id, ios_options
        when Meet4Xmas::Persistence::NotificationServiceType::MPNS
          options.merge(:message => message)
          self.send_wpns_notification notification_service.device_id, options, :toast, nil
        else
          raise "can't send notification to device type '#{notification_service.device_type}'"
        end
      end

      def self.send_apns_notification(device_token, ios_options)
          self.configure_apns
          puts "sending APNS notification to '#{device_token}' with #{ios_options}"
          APNS.send_notification device_token, ios_options
      end

      def self.send_wpns_notification(channel_uri, params, type, delay)
          puts "sending WPNS #{type} notification in the next #{delay} to '#{channel_uri}' with #{params}"
          Wpns.send_notification channel_uri, params, type, delay
      end
    end
  end
end
