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

    def create_appointment(travel_type, location, invitees, location_type, user_message)
      appointment = created_appointments.create({
        :created_at => DateTime.now,
        :location_type => location_type, :user_message => user_message
      })
      appointment.update_participation_info self, :travel_type => travel_type, :location => location
      appointment.add_participants *invitees
      if appointment.save
        return appointment
      else
        raise "Failed to save the appointment. Errors:\n#{errors.inspect}" unless save()
      end
    end
  end
end
end
