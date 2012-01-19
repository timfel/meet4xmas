require 'rubygems'
require 'dm-core'
require 'dm-transactions'
require 'dm-validations'
require 'apns'
require 'yaml'

module Meet4Xmas
  module Persistence
    class NotificationService
      include DataMapper::Resource

      property :id, Serial, :key => true
      property :device_id, Text, :required => true
      property :service_type, Integer, :required => true

      belongs_to :user, 'Meet4Xmas::Persistence::User'

      def self.configure_services
        self.load_config

        self.configure_apns
      end

      def self.load_config
        @config ||= YAML.load_file(File.join File.dirname(__FILE__) , '..', '..', 'config', 'push.yml')
      end

      def self.configure_apns
        pem_path = [File.dirname(__FILE__), '..', '..', 'config'] + @config['APNS']['pem']
        APNS.pem = File.join pem_path
        APNS.pass = @config['APNS']['pass']
      end

      ##
      # possible options for iOS:
      #  - :badge (number)
      #  - :sound (string)
      #  - other keys possible. Those are send and later processed by your iApp (at least thats what I know)
      def send_push_notification( message, options = {} )
        case service_type
        when NotificationServiceType::APNS
          apns_opts = {}
          apns_opts[:alert] = message
          #apns_opts[:badge] = options.delete :badge
          #apns_opts[:sound] = options.delete :sound
          #apns_opts[:other] = options unless options.empty?
          puts "sending APNS notification to '#{device_id}' with #{apns_opts}"
          APNS.send_notification(device_id, apns_opts)
        else
          raise "can't send notification to device type '#{device_type}'"
        end
      end
    end

    NotificationService.configure_services
  end
end
