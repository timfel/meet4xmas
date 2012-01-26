require 'rubygems'
require 'dm-core'
require 'dm-validations'

require File.expand_path('../enums', __FILE__)

module Meet4Xmas
module Persistence
  class Appointment
    include DataMapper::Resource

    property :id, Serial
    property :created_at, DateTime, :required => true
    property :user_message, String
    property :location_type, Integer, :required => true, :default => LocationType::ChristmasMarket
    belongs_to :location, 'Meet4Xmas::Persistence::Location', :required => false # TODO: validate presence if: there is a location with this location_type, and there are any active participants
    validates_within :location_type, :set => LocationType::ALL # use values of LocationType
    property :is_final, Boolean, :required => true, :default => false

    belongs_to :creator, 'Meet4Xmas::Persistence::User'
    has n, :participations, 'Meet4Xmas::Persistence::AppointmentParticipation'
    has n, :participants, 'Meet4Xmas::Persistence::User', :through => :participations, :via => :participant

    def initialize(*args, &block)
      super
      raise "Failed to save the appointment. Errors:\n#{errors.inspect}" unless save

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
      raise "Failed to save the appointment. Errors:\n#{errors.inspect}" unless save
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

      raise "Failed to save the appointment. Errors:\n#{participation.errors.inspect}" unless participation.save
    end

    def update_location
      origins = self.participations.map(&:location).compact
      dm = WebAPI::GoogleDistanceMatrix.new(origins, Location.from_type(location_type))
      target_location = dm.closest_to_all
      if target_location
        self.location = target_location
        raise "Failed to save the appointment. Errors:\n#{errors.inspect}" unless save
      end
    end

    def join(participant, travel_type, location) # participant is either a User or its id
      update_participation_info(participant, {
        :status => ParticipationStatus::Accepted,
        :travel_type => travel_type,
        :location => location
      })
    end

    def decline(participant) # participant is either a User or its id
      update_participation_info(participant, :status => ParticipationStatus::Declined)
    end

    def finalize()
      self.is_final = true
      raise "Failed to save the appointment. Errors:\n#{errors.inspect}" unless save
    end

    def travel_plan(travel_type, current_location)
      update_location unless location
      case travel_type
      when TravelType::Car
        WebAPI::GoogleDirections.new( :origin => current_location, :destination => location ).path
      when TravelType::Walk
        WebAPI::GoogleDirections.new( :mode => 'walking', :origin => current_location, :destination => location ).path
      when TravelType::PublicTransport
        WebAPI::VBBDirections.new( :origin => current_location, :destination => location ).path
      else
        [current_location, location]
      end
    end
  end

  class AppointmentParticipation
    include DataMapper::Resource

    belongs_to :participant, 'Meet4Xmas::Persistence::User', :key => true
    belongs_to :appointment, 'Meet4Xmas::Persistence::Appointment', :key => true

    # some participant properties specific to this very participation
    property :travel_type, Integer # use values of TravelType
    validates_within :travel_type, :set => TravelType::ALL, :allow_nil => true
    belongs_to :location, 'Meet4Xmas::Persistence::Location', :required => false
    property :status, Integer, :required => true, :default => ParticipationStatus::Pending
    validates_within :status, :set => ParticipationStatus::ALL # use values of ParticipationStatus
  end
end
end
