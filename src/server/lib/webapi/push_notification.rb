require 'rubygems'
require 'yaml'
require 'apns'
require 'wpns'
require 'c2dm'

module Meet4Xmas
  module WebAPI
    #
    # General push notification interface to abstract from details of different
    # push notification services, e.g. Apple Push Notification Service or
    # Google Cloud to Device Messaging Framework for Android.
    #
    # An instance of this class represents a logical push notification that may
    # be sent to different users. The notifications will be sent to all devices
    # registered with these users.
    #
    # Usage:
    # Create a new instance using #new, set the payload and recipients, and
    # invoke #send to send the notifications to all recipients.
    # It is possible to adjust the notification for each device (see #adjust_payload).
    #
    class PushNotification
      SERVICE_TYPE_MAP = {
        Meet4Xmas::Persistence::NotificationServiceType::APNS => :apns,
        Meet4Xmas::Persistence::NotificationServiceType::MPNS => :mpns,
        Meet4Xmas::Persistence::NotificationServiceType::C2DM => :c2dm
      }

      #
      # Create a new PushNotification.
      # The optional options hash could be composed as follows:
      #
      # options = {
      #   :payloads => { # all service types are optional
      #
      #     :apns => { # one notification; all keys are optional
      #       :alert => "alert"|{:body => "alert", ...},
      #       :badge => 1234,
      #       :sound => "default",
      #       :other => { :custom => :content }
      #     },
      #
      #     :c2dm => {
      #       :message => "some message",
      #       :collapse_key => "arbitrary string", # the messages are grouped on the device by that string
      #       <you may add custom key/value pairs as you like>
      #     },
      #
      #     :mpns => { # one notification; all keys are optional, except:
      #                # - should set at least one of title or message for :toast
      #                # - should set image for :tile
      #                # - should set message for :raw
      #       :type => :toast|:tile|:raw,       # default: :raw
      #       :delay => 0|:delay450|:delay900,  # default: 0
      #       :title => "title",                # for :toast and :tile
      #       :message => "message",            # for :toast and :raw
      #       :param => "param",                # for :toast
      #       :image => "image",                # for :tile
      #       :count => 123,                    # for :tile
      #       :title => "title",                # for :tile
      #       :back_image => "back image",      # for :tile
      #       :back_title => "back title",      # for :tile
      #       :back_content => "back content"   # for :tile
      #     },
      #     # or:
      #     :mpns => { # specifying more than one type sends more than one
      #                # notification per device
      #       :toast => {
      #         :title => "title",
      #         :message => "message",
      #         :param => "param",
      #         :delay => 0|:delay450|:delay900, # default: 0
      #       },
      #       :tile => {
      #         :title => "title",
      #         :image => "image",
      #         :count => 123,
      #         :title => "title",
      #         :back_image => "back image",
      #         :back_title => "back title",
      #         :back_content => "back content",
      #         :delay => 0|:delay450|:delay900, # default: 0
      #       },
      #       :raw => {
      #         :message => "raw payload",
      #         :delay => 0|:delay450|:delay900, # default: 0
      #       },
      #       # option to set default delay for all notification types:
      #       :delay => 0|:delay450|:delay900
      #     }
      #   },
      #
      #   :recipients => [] # Meet4Xmas::Persistence::Users
      # }
      #
      # The payloads hash contains general payload for each notification service type.
      # You can adjust the payload to a specific device using #adjust_payload.
      #
      # Recipients is a list of users that should receive the notification. It will be sent
      # to all their registered devices.
      #
      def initialize(options = {})
        @payloads = options.delete(:payloads) || {}
        @recipients = options.delete(:recipients) || []
        @notification_args = {:apns => [], :mpns => [], :c2dm => []}

        default_handler = Proc.new { |device, payload| payload }
        @adjust_payload = {
          :apns => default_handler,
          :mpns => default_handler,
          :c2dm => default_handler
        }
      end

      attr_accessor :payloads, :recipients

      #
      # Get or set the routine that adjusts the payload hash to a specific device.
      # This can be handy if you want to set the :badge value in APNS for each
      # user independently.
      #
      # @param [Symbol] The name of the service type (see values of SERVICE_TYPE_MAP)
      # @param [Proc] If given the routine to adjust the payload is set to this Proc.
      #   It should be a Proc that takes two arguments (the device and the standard payload).
      #   The default implementation is:
      #     notification.adjust_payload :apns do |device, payload| payload end
      # @returns the new value of the adjust_payload routine (or the existing one if
      #   none was given).
      #
      def adjust_payload(service_name, &block)
        @adjust_payload[service_name] = block if block_given?
        @adjust_payload[service_name]
      end

      #
      # Send the notification to all devices of all recipients.
      #
      # See also: #build_notification_args, #build_sendable_notifications, #send_notifications
      #
      def send
        # sort devices by notification service type
        services = @recipients.each do |recipient|
          recipient.devices.each do |device|
            build_notification_args(device)
          end
        end
        # send them
        @notification_args.each do |service_name, notifications|
          self.send_notifications(
            service_name,
            notifications.compact.map do |notification|
              self.build_sendable_notifications(service_name, *notification)
            end.flatten(1).compact
          )
        end
      rescue => e
        puts "Error in PushNotification.send! - #{e}"
        puts e.backtrace
      end

      #
      # Use #adjust_payload to adapt the general payload to a specific device.
      # The result is stored in a list for the device's service type, as a tuple of
      # device id and adjusted payload.
      #
      def build_notification_args(device)
        service_name = SERVICE_TYPE_MAP[device.notification_service_type]
        payload = @payloads[service_name]
        payload = adjust_payload(service_name).call(device, payload) unless payload == nil
        @notification_args[service_name] << [device.device_id, payload] unless payload == nil
      rescue => e
        puts "Error in PushNotification.build_notification_args(#{device}) - #{e}"
        puts e.backtrace
      end

      #
      # Map from the payload Hash for a single service type to a representation which
      # can be passed to the client. I.e. the payload Hash (which is independent of
      # the service client implementation) is mapped to a (implementation-specific)
      # argument for the service client.
      #
      # It might also create multiple notifications per device, i.e. this method
      # returns a list of notifications.
      #
      # See also: #send_notifications
      #
      def build_sendable_notifications(service_name, device_id, payload)
        case service_name
        when :apns
          [APNS::Notification.new(device_id, payload)]
        when :mpns
          # if type is given, only one notification is built
          type = payload.delete :type
          if type
            delay = payload.delete :delay
            [[device_id, payload, type, delay]]
          else
            # can send multiple notification types
            [:toast, :tile, :raw].map do |type|
              type_payload = payload.delete type
              if type_payload
                # type-specific delay overrides global delay
                delay = type_payload.key?(:delay) ? type_payload.delete(:delay) : payload[:delay]
                [device_id, type_payload, type, delay]
              else
                nil
              end
            end.compact
          end
        when :c2dm
          collapse_key = payload.delete :collapse_key
          [{ :registration_id => device_id, :data => payload, :collapse_key => collapse_key }]
        else
          puts "Error: unsupported notification service type: #{service_name}"
        end
      rescue => e
        puts "Error in PushNotification.build_sendable_notifications(#{service_name}, #{device_id}, #{payload}) - #{e}"
        puts e.backtrace
      end

      #
      # Send several notifications to the notification service named.
      #
      # We try to send the notifications in batches, i.e. use a single connection
      # to a particular notification service to send the notifications to all
      # devices of that service.
      #
      # The method is as fault-proof as possible: instead of failing in case of an
      # exception, it will rescue from any exception and just log it.
      # We also try to make sure that we send as many notifications as possible
      # (instead of stopping if a single notification cannot be sent).
      #
      def send_notifications(service_name, notifications)
        return if notifications.empty?
        puts "sending #{service_name} notifications: #{notifications}"

        case service_name
        when :apns
          self.class.configure_apns
          sock, ssl = APNS.send :open_connection
          notifications.each do |notification|
            begin
              ssl.write notification.packaged_notification
            rescue => e
              puts "Error in while sending #{service_name} notification (#{notification}) - #{e}"
              puts e.backtrace
            end
          end
          ssl.close
          sock.close
        when :mpns
          notifications.map do |notification|
            begin
              Wpns.send_notification(*notification)
            rescue => e
              puts "Error in while sending #{service_name} notification (#{notification}) - #{e}"
              puts e.backtrace
            end
          end
        when :c2dm
          c2dm = C2DM.new('meet4xmas@googlemail.com', 'WerWillSichMitMirTreffen?', 'HPIStudents-Meet4Xmas-0.1')
          notifications.each do |notification|
            begin
              c2dm.send_notification(notification)
            rescue => e
              puts "Error in while sending #{service_name} notification (#{notification}) - #{e}"
              puts e.backtrace
            end
          end
        else
          puts "Error: unsupported notification service type: #{service_name}"
        end
      rescue => e
        puts "Error in PushNotification.send_notifications(#{service_name}, #{notifications}) - #{e}"
        puts e.backtrace
      end

      # Load a yaml config file with global parameters for the push notification service.
      def self.load_config
        @config ||= YAML.load_file(File.join File.dirname(__FILE__) , '..', '..', 'config', 'push.yml')
      end

      #
      # Configure global APNS options (pem file and passphrase, optionally host and port)
      # using the config.
      #
      # See also: #load_config
      #
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
    end

    #
    # Notifies all invitees about a new appointment they were invited to.
    #
    class InvitationPushNotification < PushNotification
      def initialize(appointment)
        @appointment = appointment
        short_message = "Invitation from #{@appointment.creator.id}"
        super({
          :payloads => {
            :apns => {
              :alert => @appointment.user_message ? @appointment.user_message : short_message
            },
            :mpns => {
              :toast => {
                :title => @appointment.user_message || "Invitation",
                :message => short_message,
                :param => "/MainPage.xaml?appointmentId=#{@appointment.id}"
              },
              :tile => {
                :back_title => "#{@appointment.creator.id} says:",
                :back_content => @appointment.user_message || "Invitation!"
              },
            },
            :c2dm => {
              :message => @appointment.user_message ? @appointment.user_message : short_message
            }
          },
          :recipients => @appointment.participants.reject{|p|p.id == @appointment.creator.id}
        })
      end
    end
  end
end
