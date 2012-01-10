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
      require 'net/http'

      locations = Location.from_type location_type
      origins = URI.escape(self.participations.map{|p|"#{p.location.latitude},#{p.location.longitude}"}.join('|'))

      googleResults = nil
      while locations.count > 0
        destinations = URI.escape(locations.shift(50).map{ |l| "#{l.latitude},#{l.longitude}" }.join('|'))
        base_url = "http://maps.googleapis.com/maps/api/distancematrix/json"
        url = "#{base_url}?sensor=false&origins=#{origins}&destinations=#{destinations}"
        uri = URI.parse(url)

        resp = Net::HTTP.get_response(uri)
        case resp
        when Net::HTTPSuccess
          data = resp.body
          result = JSON.parse(data)
          unless googleResults
            googleResults = result['rows']
          else
            result['rows'].each_with_index do |row,index|
              googleResults[index]['elements'] += row['elements']
            end
          end
        else
          puts "Unexpected response #{resp}"
        end
      end

      locations = Location.from_type(location_type)
      destinationDistances = [0] * locations.count
      googleResults.each do |row| # one origin
        row['elements'].each_with_index do |element, index| # one destination
          destinationDistances[index] += element['duration']['value']
        end
      end

      minDistance = Float::INFINITY
      minIndex = nil
      destinationDistances.each_with_index do |distance, index|
        if distance < minDistance
          minIndex = index
          minDistance = distance
        end
      end
      if minIndex
        self.location = locations[minIndex]
      end
      puts minIndex
      puts self.location
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
      [current_location, location]
    end
  end

  class AppointmentParticipation
    include DataMapper::Resource

    belongs_to :participant, 'Meet4Xmas::Persistence::User', :key => true
    belongs_to :appointment, 'Meet4Xmas::Persistence::Appointment', :key => true

    # some participant properties specific to this very participation
    property :travel_type, Integer # use values of TravelType
    validates_within :travel_type, :set => TravelType::ALL, :allow_nil => true
    belongs_to :location, :required => false, :allow_nil => true # XXX
    property :status, Integer, :required => true, :default => ParticipationStatus::Pending
    validates_within :status, :set => ParticipationStatus::ALL # use values of ParticipationStatus
  end
end
end
