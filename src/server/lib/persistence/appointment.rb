require 'rubygems'
require 'dm-core'
require 'dm-validations'

require File.expand_path('../enums', __FILE__)

module Persistence
  class Appointment
    include DataMapper::Resource

    property :id, Serial
    property :created_at, DateTime, :required => true
    property :user_message, String
    property :location_type, Integer, :required => true, :default => LocationType::ChristmasMarket
    validates_within :location_type, :set => LocationType::ALL # use values of Persistence::LocationType
    property :is_final, Boolean, :required => true, :default => false

    belongs_to :creator, 'Persistence::User'
    has n, :participations, 'Persistence::AppointmentParticipation'
    has n, :participants, 'Persistence::User', :through => :participations, :via => :participant

    def initialize(*args, &block)
    	super
    	save

    	# add the creator to the participants
    	add_participants creator
    	update_participation_info creator, :status => ParticipationStatus::Accepted

    	self
    end

    def add_participants(*invitees) # either resources or their ids
    	invitees.each do |invitee|
    		unless invitee.kind_of? User
    			inviteeObj = User.first(:id => invitee)
    			raise "User '#{invitee}' does not exist" unless inviteeObj
    			invitee = inviteeObj
    		end
    		participations.create(:participant => invitee)
    	end
    	save
    end

    def update_participation_info(participant, attributes)
    	# participant is either a User or its id
    	# attributes will be passed to AppointmentParticipation#update

    	unless participant.kind_of? User
  			participantObj = User.first(:id => participant)
  			raise "User '#{participant}' does not exist" unless participantObj
  			participant = participantObj
  		end
  		participation = participations.first(:participant => participant)
  		raise "User '#{participant.id}' does not participate in appointment #{id}" unless participation
  		participation.update attributes
      save
    end

    def join(participant, travel_type, location) # participant is either a User or its id
      update_participation_info(participant, {
        :status => ParticipationStatus::Accepted,
        :travel_type => travel_type
        #:location => location # TODO
      })
    end

    def decline(participant) # participant is either a User or its id
      update_participation_info(participant, :status => ParticipationStatus::Declined)
    end

    def finalize()
      self.is_final = true
      save
    end
  end

  class AppointmentParticipation
  	include DataMapper::Resource

  	belongs_to :participant, 'Persistence::User', :key => true
  	belongs_to :appointment, 'Persistence::Appointment', :key => true

  	# some participant properties specific to this very participation
  	property :travel_type, Integer
    validates_within :travel_type, :set => TravelType::ALL # use values of Persistence::TravelType
  	# has 1, :location # TODO
  	property :status, Integer, :required => true, :default => ParticipationStatus::Pending
    validates_within :status, :set => ParticipationStatus::ALL # use values of Persistence::ParticipationStatus
  end
end