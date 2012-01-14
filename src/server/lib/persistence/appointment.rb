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
      if false # don't mock
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
      else # mock
        googleResults = [{"elements"=>[{"distance"=>{"text"=>"25.5 km", "value"=>25490}, "duration"=>{"text"=>"22 mins", "value"=>1327}, "status"=>"OK"}, {"distance"=>{"text"=>"24.1 km", "value"=>24091}, "duration"=>{"text"=>"25 mins", "value"=>1500}, "status"=>"OK"}, {"distance"=>{"text"=>"22.2 km", "value"=>22233}, "duration"=>{"text"=>"23 mins", "value"=>1400}, "status"=>"OK"}, {"distance"=>{"text"=>"13.4 km", "value"=>13354}, "duration"=>{"text"=>"17 mins", "value"=>1038}, "status"=>"OK"}, {"distance"=>{"text"=>"25.0 km", "value"=>25018}, "duration"=>{"text"=>"23 mins", "value"=>1385}, "status"=>"OK"}, {"distance"=>{"text"=>"22.9 km", "value"=>22879}, "duration"=>{"text"=>"23 mins", "value"=>1364}, "status"=>"OK"}, {"distance"=>{"text"=>"18.7 km", "value"=>18686}, "duration"=>{"text"=>"19 mins", "value"=>1154}, "status"=>"OK"}, {"distance"=>{"text"=>"22.7 km", "value"=>22716}, "duration"=>{"text"=>"22 mins", "value"=>1331}, "status"=>"OK"}, {"distance"=>{"text"=>"22.6 km", "value"=>22566}, "duration"=>{"text"=>"20 mins", "value"=>1180}, "status"=>"OK"}, {"distance"=>{"text"=>"32.5 km", "value"=>32509}, "duration"=>{"text"=>"40 mins", "value"=>2396}, "status"=>"OK"}, {"distance"=>{"text"=>"33.8 km", "value"=>33776}, "duration"=>{"text"=>"41 mins", "value"=>2477}, "status"=>"OK"}, {"distance"=>{"text"=>"44.3 km", "value"=>44275}, "duration"=>{"text"=>"53 mins", "value"=>3159}, "status"=>"OK"}, {"distance"=>{"text"=>"42.9 km", "value"=>42931}, "duration"=>{"text"=>"51 mins", "value"=>3038}, "status"=>"OK"}, {"distance"=>{"text"=>"43.0 km", "value"=>42977}, "duration"=>{"text"=>"50 mins", "value"=>3004}, "status"=>"OK"}, {"distance"=>{"text"=>"40.7 km", "value"=>40749}, "duration"=>{"text"=>"48 mins", "value"=>2872}, "status"=>"OK"}, {"distance"=>{"text"=>"28.7 km", "value"=>28684}, "duration"=>{"text"=>"34 mins", "value"=>2013}, "status"=>"OK"}, {"distance"=>{"text"=>"25.2 km", "value"=>25245}, "duration"=>{"text"=>"30 mins", "value"=>1793}, "status"=>"OK"}, {"distance"=>{"text"=>"28.4 km", "value"=>28370}, "duration"=>{"text"=>"34 mins", "value"=>2035}, "status"=>"OK"}, {"distance"=>{"text"=>"30.4 km", "value"=>30368}, "duration"=>{"text"=>"32 mins", "value"=>1894}, "status"=>"OK"}, {"distance"=>{"text"=>"28.9 km", "value"=>28899}, "duration"=>{"text"=>"30 mins", "value"=>1784}, "status"=>"OK"}, {"distance"=>{"text"=>"29.4 km", "value"=>29367}, "duration"=>{"text"=>"31 mins", "value"=>1836}, "status"=>"OK"}, {"distance"=>{"text"=>"33.6 km", "value"=>33598}, "duration"=>{"text"=>"32 mins", "value"=>1898}, "status"=>"OK"}, {"distance"=>{"text"=>"28.4 km", "value"=>28373}, "duration"=>{"text"=>"27 mins", "value"=>1635}, "status"=>"OK"}, {"distance"=>{"text"=>"38.4 km", "value"=>38410}, "duration"=>{"text"=>"31 mins", "value"=>1853}, "status"=>"OK"}, {"distance"=>{"text"=>"38.4 km", "value"=>38410}, "duration"=>{"text"=>"31 mins", "value"=>1853}, "status"=>"OK"}, {"distance"=>{"text"=>"33.9 km", "value"=>33881}, "duration"=>{"text"=>"28 mins", "value"=>1659}, "status"=>"OK"}, {"distance"=>{"text"=>"35.8 km", "value"=>35771}, "duration"=>{"text"=>"31 mins", "value"=>1876}, "status"=>"OK"}, {"distance"=>{"text"=>"36.5 km", "value"=>36487}, "duration"=>{"text"=>"30 mins", "value"=>1826}, "status"=>"OK"}, {"distance"=>{"text"=>"33.6 km", "value"=>33616}, "duration"=>{"text"=>"27 mins", "value"=>1623}, "status"=>"OK"}, {"distance"=>{"text"=>"34.3 km", "value"=>34298}, "duration"=>{"text"=>"30 mins", "value"=>1775}, "status"=>"OK"}, {"distance"=>{"text"=>"39.7 km", "value"=>39701}, "duration"=>{"text"=>"32 mins", "value"=>1915}, "status"=>"OK"}, {"distance"=>{"text"=>"33.9 km", "value"=>33874}, "duration"=>{"text"=>"34 mins", "value"=>2052}, "status"=>"OK"}, {"distance"=>{"text"=>"32.2 km", "value"=>32190}, "duration"=>{"text"=>"35 mins", "value"=>2127}, "status"=>"OK"}, {"distance"=>{"text"=>"39.7 km", "value"=>39673}, "duration"=>{"text"=>"39 mins", "value"=>2356}, "status"=>"OK"}, {"distance"=>{"text"=>"33.8 km", "value"=>33795}, "duration"=>{"text"=>"33 mins", "value"=>1968}, "status"=>"OK"}, {"distance"=>{"text"=>"28.2 km", "value"=>28226}, "duration"=>{"text"=>"24 mins", "value"=>1437}, "status"=>"OK"}, {"distance"=>{"text"=>"30.8 km", "value"=>30789}, "duration"=>{"text"=>"26 mins", "value"=>1553}, "status"=>"OK"}, {"distance"=>{"text"=>"36.9 km", "value"=>36865}, "duration"=>{"text"=>"32 mins", "value"=>1890}, "status"=>"OK"}, {"distance"=>{"text"=>"36.9 km", "value"=>36869}, "duration"=>{"text"=>"32 mins", "value"=>1891}, "status"=>"OK"}, {"distance"=>{"text"=>"22.3 km", "value"=>22334}, "duration"=>{"text"=>"27 mins", "value"=>1630}, "status"=>"OK"}, {"distance"=>{"text"=>"23.2 km", "value"=>23178}, "duration"=>{"text"=>"28 mins", "value"=>1698}, "status"=>"OK"}, {"distance"=>{"text"=>"26.8 km", "value"=>26820}, "duration"=>{"text"=>"34 mins", "value"=>2017}, "status"=>"OK"}, {"distance"=>{"text"=>"28.9 km", "value"=>28887}, "duration"=>{"text"=>"27 mins", "value"=>1601}, "status"=>"OK"}, {"distance"=>{"text"=>"16.4 km", "value"=>16424}, "duration"=>{"text"=>"21 mins", "value"=>1271}, "status"=>"OK"}, {"distance"=>{"text"=>"18.6 km", "value"=>18584}, "duration"=>{"text"=>"25 mins", "value"=>1495}, "status"=>"OK"}, {"distance"=>{"text"=>"11.5 km", "value"=>11521}, "duration"=>{"text"=>"14 mins", "value"=>857}, "status"=>"OK"}, {"distance"=>{"text"=>"17.1 km", "value"=>17125}, "duration"=>{"text"=>"19 mins", "value"=>1124}, "status"=>"OK"}, {"distance"=>{"text"=>"13.1 km", "value"=>13070}, "duration"=>{"text"=>"15 mins", "value"=>914}, "status"=>"OK"}, {"distance"=>{"text"=>"8.8 km", "value"=>8810}, "duration"=>{"text"=>"11 mins", "value"=>668}, "status"=>"OK"}, {"distance"=>{"text"=>"13.7 km", "value"=>13696}, "duration"=>{"text"=>"16 mins", "value"=>986}, "status"=>"OK"}, {"distance"=>{"text"=>"28.9 km", "value"=>28915}, "duration"=>{"text"=>"33 mins", "value"=>1997}, "status"=>"OK"}, {"distance"=>{"text"=>"24.0 km", "value"=>23953}, "duration"=>{"text"=>"28 mins", "value"=>1661}, "status"=>"OK"}, {"distance"=>{"text"=>"24.2 km", "value"=>24176}, "duration"=>{"text"=>"28 mins", "value"=>1696}, "status"=>"OK"}, {"distance"=>{"text"=>"36.2 km", "value"=>36194}, "duration"=>{"text"=>"32 mins", "value"=>1893}, "status"=>"OK"}, {"distance"=>{"text"=>"24.2 km", "value"=>24217}, "duration"=>{"text"=>"28 mins", "value"=>1699}, "status"=>"OK"}, {"distance"=>{"text"=>"48.9 km", "value"=>48877}, "duration"=>{"text"=>"44 mins", "value"=>2645}, "status"=>"OK"}, {"distance"=>{"text"=>"47.1 km", "value"=>47122}, "duration"=>{"text"=>"40 mins", "value"=>2377}, "status"=>"OK"}, {"distance"=>{"text"=>"35.7 km", "value"=>35686}, "duration"=>{"text"=>"29 mins", "value"=>1714}, "status"=>"OK"}, {"distance"=>{"text"=>"49.6 km", "value"=>49577}, "duration"=>{"text"=>"45 mins", "value"=>2729}, "status"=>"OK"}, {"distance"=>{"text"=>"40.0 km", "value"=>39966}, "duration"=>{"text"=>"35 mins", "value"=>2107}, "status"=>"OK"}, {"distance"=>{"text"=>"44.9 km", "value"=>44904}, "duration"=>{"text"=>"37 mins", "value"=>2193}, "status"=>"OK"}, {"distance"=>{"text"=>"135 km", "value"=>135123}, "duration"=>{"text"=>"1 hour 30 mins", "value"=>5381}, "status"=>"OK"}, {"distance"=>{"text"=>"86.6 km", "value"=>86643}, "duration"=>{"text"=>"1 hour 0 mins", "value"=>3627}, "status"=>"OK"}, {"distance"=>{"text"=>"81.7 km", "value"=>81711}, "duration"=>{"text"=>"55 mins", "value"=>3306}, "status"=>"OK"}, {"distance"=>{"text"=>"59.2 km", "value"=>59170}, "duration"=>{"text"=>"43 mins", "value"=>2556}, "status"=>"OK"}, {"distance"=>{"text"=>"132 km", "value"=>132030}, "duration"=>{"text"=>"1 hour 28 mins", "value"=>5298}, "status"=>"OK"}, {"distance"=>{"text"=>"109 km", "value"=>108678}, "duration"=>{"text"=>"1 hour 11 mins", "value"=>4234}, "status"=>"OK"}, {"distance"=>{"text"=>"28.6 km", "value"=>28554}, "duration"=>{"text"=>"37 mins", "value"=>2230}, "status"=>"OK"}, {"distance"=>{"text"=>"121 km", "value"=>120870}, "duration"=>{"text"=>"1 hour 19 mins", "value"=>4710}, "status"=>"OK"}, {"distance"=>{"text"=>"39.8 km", "value"=>39764}, "duration"=>{"text"=>"35 mins", "value"=>2101}, "status"=>"OK"}, {"distance"=>{"text"=>"66.6 km", "value"=>66620}, "duration"=>{"text"=>"59 mins", "value"=>3551}, "status"=>"OK"}, {"distance"=>{"text"=>"31.8 km", "value"=>31773}, "duration"=>{"text"=>"40 mins", "value"=>2414}, "status"=>"OK"}, {"distance"=>{"text"=>"59.2 km", "value"=>59172}, "duration"=>{"text"=>"43 mins", "value"=>2584}, "status"=>"OK"}, {"distance"=>{"text"=>"54.7 km", "value"=>54685}, "duration"=>{"text"=>"38 mins", "value"=>2308}, "status"=>"OK"}, {"distance"=>{"text"=>"63.1 km", "value"=>63142}, "duration"=>{"text"=>"59 mins", "value"=>3555}, "status"=>"OK"}, {"distance"=>{"text"=>"75.6 km", "value"=>75636}, "duration"=>{"text"=>"57 mins", "value"=>3436}, "status"=>"OK"}, {"distance"=>{"text"=>"49.3 km", "value"=>49335}, "duration"=>{"text"=>"47 mins", "value"=>2841}, "status"=>"OK"}, {"distance"=>{"text"=>"118 km", "value"=>118192}, "duration"=>{"text"=>"1 hour 31 mins", "value"=>5489}, "status"=>"OK"}, {"distance"=>{"text"=>"115 km", "value"=>114777}, "duration"=>{"text"=>"1 hour 17 mins", "value"=>4599}, "status"=>"OK"}, {"distance"=>{"text"=>"36.4 km", "value"=>36381}, "duration"=>{"text"=>"35 mins", "value"=>2109}, "status"=>"OK"}, {"distance"=>{"text"=>"37.4 km", "value"=>37363}, "duration"=>{"text"=>"36 mins", "value"=>2146}, "status"=>"OK"}, {"distance"=>{"text"=>"80.6 km", "value"=>80578}, "duration"=>{"text"=>"1 hour 0 mins", "value"=>3570}, "status"=>"OK"}, {"distance"=>{"text"=>"147 km", "value"=>147419}, "duration"=>{"text"=>"1 hour 41 mins", "value"=>6085}, "status"=>"OK"}, {"distance"=>{"text"=>"80.8 km", "value"=>80831}, "duration"=>{"text"=>"1 hour 13 mins", "value"=>4409}, "status"=>"OK"}, {"distance"=>{"text"=>"53.8 km", "value"=>53776}, "duration"=>{"text"=>"41 mins", "value"=>2460}, "status"=>"OK"}, {"distance"=>{"text"=>"5.9 km", "value"=>5870}, "duration"=>{"text"=>"9 mins", "value"=>515}, "status"=>"OK"}, {"distance"=>{"text"=>"6.6 km", "value"=>6571}, "duration"=>{"text"=>"12 mins", "value"=>719}, "status"=>"OK"}, {"distance"=>{"text"=>"3.0 km", "value"=>3025}, "duration"=>{"text"=>"6 mins", "value"=>361}, "status"=>"OK"}, {"distance"=>{"text"=>"9.6 km", "value"=>9621}, "duration"=>{"text"=>"15 mins", "value"=>905}, "status"=>"OK"}, {"distance"=>{"text"=>"5.8 km", "value"=>5785}, "duration"=>{"text"=>"10 mins", "value"=>602}, "status"=>"OK"}, {"distance"=>{"text"=>"5.7 km", "value"=>5731}, "duration"=>{"text"=>"10 mins", "value"=>627}, "status"=>"OK"}, {"distance"=>{"text"=>"71.0 km", "value"=>71036}, "duration"=>{"text"=>"46 mins", "value"=>2765}, "status"=>"OK"}, {"distance"=>{"text"=>"12.7 km", "value"=>12654}, "duration"=>{"text"=>"19 mins", "value"=>1148}, "status"=>"OK"}, {"distance"=>{"text"=>"16.3 km", "value"=>16304}, "duration"=>{"text"=>"22 mins", "value"=>1298}, "status"=>"OK"}, {"distance"=>{"text"=>"170 km", "value"=>169960}, "duration"=>{"text"=>"2 hours 5 mins", "value"=>7515}, "status"=>"OK"}, {"distance"=>{"text"=>"57.7 km", "value"=>57694}, "duration"=>{"text"=>"44 mins", "value"=>2613}, "status"=>"OK"}]}]
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
