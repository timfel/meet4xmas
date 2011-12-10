require 'rubygems'
require 'dm-core'

module Persistence
  class User
    include DataMapper::Resource

    property :id, String, :key => true

    has n, :created_appointments, 'Persistence::Appointment', :child_key => [ :creator_id ]
    has n, :appointment_participations, :child_key => [ :participant_id ]
    has n, :appointments, :through => :appointment_participations, :via => :appointment

end
