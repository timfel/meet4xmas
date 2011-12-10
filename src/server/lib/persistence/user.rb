require 'rubygems'
require 'dm-core'
require 'dm-transactions'

module Persistence
  class User
    include DataMapper::Resource

    property :id, String, :key => true

    has n, :created_appointments, 'Persistence::Appointment', :child_key => [ :creator_id ]
    has n, :appointment_participations, :child_key => [ :participant_id ]
    has n, :appointments, :through => :appointment_participations, :via => :appointment

    def create_appointment(travel_type, location, invitees, location_type, user_message)
      User.transaction do
        appointment = created_appointments.create({
          :created_at => DateTime.now,
          :location_type => location_type, :user_message => user_message
        })
        appointment.update_participation_info self, :travel_type => travel_type
        appointment.add_participants *invitees
        appointment.save
        appointment
      end
    end
  end
end
