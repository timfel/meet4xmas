require 'rubygems'
require 'dm-core'

require File.expand_path('../enums', __FILE__)

module Persistence
  class Appointment
    include DataMapper::Resource

    property :id, Serial
    property :created_at, DateTime, :required => true
    property :user_message, String
    property :location_type, Integer, :required => true, :default => LocationType::ChristmasMarket
    	# use values of Persistence::LocationType

    belongs_to :creator, 'Persistence::User'
    has n, :participations, 'Persistence::AppointmentParticipation'
    has n, :participants, 'Persistence::User', :through => :participations, :via => :participant
  end

  class AppointmentParticipation
  	include DataMapper::Resource

  	belongs_to :participant, 'Persistence::User', :key => true
  	belongs_to :appointment, 'Persistence::Appointment', :key => true

  	# some participant properties specific to this very participation
  	property :travel_type, Integer # use values of Persistence::TravelType
  	property :status, Integer, :required => true, :default => ParticipationStatus::Pending
  	# use values of Persistence::ParticipationStatus
  end
end