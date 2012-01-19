require 'rubygems'
require 'dm-core'
require 'dm-transactions'
require 'dm-validations'

module Meet4Xmas
module Persistence
  class User
    include DataMapper::Resource

    property :id, String, :key => true, :format => :email_address

    has n, :created_appointments, 'Meet4Xmas::Persistence::Appointment', :child_key => [ :creator_id ]
    has n, :appointment_participations, :child_key => [ :participant_id ]
    has n, :appointments, :through => :appointment_participations, :via => :appointment
    has n, :notification_services, 'Meet4Xmas::Persistence::NotificationService'

    def create_appointment(travel_type, location, invitees, location_type, user_message)
      appointment = created_appointments.create({
        :created_at => DateTime.now,
        :location_type => location_type, :user_message => user_message
      })
      appointment.update_participation_info self, :travel_type => travel_type, :location => location
      appointment.update_location # find the initial location
      appointment.add_participants(*invitees)

      send_notifications appointment
      if appointment.save
        return appointment
      else
        raise "Failed to save the appointment. Errors:\n#{errors.inspect}" unless save
      end
    end

    def send_notifications appointment
      begin
        invitees = appointment.participants.reject{|p|p.id == appointment.creator.id}
        invitees.each do |invitee|
          begin
            invitee.notification_services.each do |ns|
              begin
                Meet4Xmas::WebAPI::NotificationService.send_notification ns, "#{appointment.creator.id} sent you an invitation"
              rescue => e
                p e, e.backtrace
              end
            end
          rescue => e
            p e, e.backtrace
          end
        end
      rescue => e
        p e, e.backtrace
      end
    end

    def update_notification_services(device_id, service_type)
      # convert binary to string
      case service_type
      when Meet4Xmas::Persistence::NotificationServiceType::APNS
        device_id = device_id.unpack('H*')[0]
      when Meet4Xmas::Persistence::NotificationServiceType::MPNS, Meet4Xmas::Persistence::NotificationServiceType::C2DM
        device_id = device_id.unpack('U*')[0]
      end

      # create a new entry in this user's notification_services list, if an equal entry does not exist yet
      ns = self.notification_services.first_or_create :device_id => device_id, :service_type => service_type
      unless ns.save
        raise "cannot save notification service information #{[device_id, service_type]} of user #{self}"
      end
      ns
    end
  end
end
end
