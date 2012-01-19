require 'rubygems'
require 'dm-core'
require 'dm-transactions'
require 'dm-validations'
require 'apns'

module Meet4Xmas
  module Persistence
    class NotificationService
      include DataMapper::Resource

      property :id, Serial, :key => true
      property :device_id, Text, :required => true
      property :service_type, Integer, :required => true

      belongs_to :user, 'Meet4Xmas::Persistence::User'

      def self.configure_apns
        # APNS.host = 'gateway.push.apple.com'
        # gateway.sandbox.push.apple.com is default

        APNS.pem = File.join File.dirname(__FILE__), '..', '..', 'config', 'apns.pem'
        APNS.pass = 'S3H1E4G1A5L9K2I6N'

        # this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.
        # APNS.port = 2195
      end

      ##
      # possible options for iOS:
      #  - :badge (number)
      #  - :sound (string)
      #  - other keys possible. Those are send and later processed by your iApp (at least thats what I know)
      def send_push_notification( message, options = {} )
        case service_type
        when NotificationServiceType::APNS
          apns_opts[:badge] = options.delete :badge if options[:badge]
          apns_opts[:sound] = options.delete :sound if options[:sound]
          apns_opts[:other] = options unless options.empty?
          APNS.send_notification(device_id, apns_opts)
        else
          raise "can't send notification to unknown device id #{device_type}!"
        end
      end
    end

    NotificationService.configure_apns
  end
end
