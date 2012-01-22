require 'rubygems'
require 'yaml'
require 'apns'
require 'wpns'

module Meet4Xmas
  module WebAPI
    class PushNotification
      SERVICE_TYPE_MAP = {
        Meet4Xmas::Persistence::NotificationServiceType::APNS => :apns,
        Meet4Xmas::Persistence::NotificationServiceType::MPNS => :mpns,
        Meet4Xmas::Persistence::NotificationServiceType::C2DM => :c2dm
      }

      # options = {
      #   :payloads => {
      #     :apns => {
      #       :alert => "alert",
      #       :badge => 1234,
      #       :sound => "default",
      #       :other => { :custom => :content }
      #     },
      #     :mpns => {
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
      #     :c2dm => {
      #       # TODO
      #     }
      #   },
      #   :recipients => [] # Users
      # }
      def initialize(options = {})
        @payloads = options.delete(:payloads) || {:apns => {}, :mpns => {}, :c2dm => {}}
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

      def adjust_payload(service_name, &block)
        @adjust_payload[service_name] = block if block_given?
        @adjust_payload[service_name]
      end

      def send
        # sort devices by notification service type
        services = @recipients.each do |recipient|
          recipient.devices.each do |device|
            build_notification_args(device)
          end
        end
        # send notifications of one type in batches
        @notification_args.each do |service_name, notifications|
          self.send_notifications(
            service_name,
            notifications.compact.map{|n|self.build_sendable_notification(service_name, *n)}.compact
          )
        end
      rescue => e
        puts "Error in PushNotification.send! - #{e}"
        puts e.backtrace
      end

      def build_notification_args(device)
        service_name = SERVICE_TYPE_MAP[device.notification_service_type]
        adjusted_payload = adjust_payload(service_name).call(device, @payloads[service_name])
        @notification_args[service_name] << [device.device_id, adjusted_payload]
      rescue => e
        puts "Error in PushNotification.build_notification_args(#{device}) - #{e}"
        puts e.backtrace
      end

      def build_sendable_notification(service_name, device_id, payload)
        case service_name
        when :apns
          APNS::Notification.new(device_id, payload)
        when :mpns
          type = payload.delete(:type) || :raw
          delay = payload.delete :delay
          [device_id, payload, type, delay]
        when :c2dm
          # TODO
        else
          puts "Error: unsupported notification service type: #{service_name}"
        end
      rescue => e
        puts "Error in PushNotification.build_sendable_notification(#{service_name}, #{device_id}, #{payload}) - #{e}"
        puts e.backtrace
      end

      def send_notifications(service_name, notifications)
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
          # TODO
        else
          puts "Error: unsupported notification service type: #{service_name}"
        end
      rescue => e
        puts "Error in PushNotification.send_notifications(#{service_name}, #{notifications}) - #{e}"
        puts e.backtrace
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
    end

    class InvitationPushNotification < PushNotification
      def initialize(appointment)
        @appointment = appointment
        short_message = "#{@appointment.creator.id} sent you an invitation"
        super({
          :payloads => {
            :apns => {
              :alert => @appointment.user_message ? "#{@appointment.user_message}: #{short_message}" : short_message
            },
            :mpns => {
              :type => :toast,
              :title => @appointment.user_message || "Invitation",
              :message => short_message
            },
            :c2dm => {
              # TODO
            }
          },
          :recipients => @appointment.participants.reject{|p|p.id == @appointment.creator.id}
        })
      end
    end
  end
end
