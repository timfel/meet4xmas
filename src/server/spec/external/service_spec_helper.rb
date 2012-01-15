#
# server config overrides
#

$MEET4XMAS_NO_LOGGING = true if $MEET4XMAS_NO_LOGGING == nil

module Meet4Xmas
  module Persistence
    DB_FILE = 'sqlite::memory:'
  end
end

#
# server and client implementation
#

# require server implementation & api info
require File.expand_path('../../../lib/server', __FILE__)
require File.expand_path('../../../lib/server/api', __FILE__)

# require hessian client
require File.expand_path('../../../lib/hessian_client/lib/hessian', __FILE__)

#
# helpers
#

module Helpers
  # server setup & connection

  def _start_server(port =4568)
    @_port = port
    @_server = Meet4Xmas::Server::run @_port
  end

  def _stop_server
    @_server.stop
  end

  def _connect
    @_address = "http://localhost:#{@_port}/#{Meet4Xmas::Server::API::VERSION}/"
    @client = Hessian::HessianClient.new(@_address)
  end

  def _cleanup_db
    # recreate database
    DataMapper.auto_migrate!

    # we must also reload caches that are built on top of the database
    Meet4Xmas::Persistence::Location.clear_caches
  end

  # user registration

  def register_account(user_id)
    @client.registerAccount user_id
  end

  def delete_account(user_id)
    @client.deleteAccount user_id
  end

  def register_users(*users)
    users.each { |user_id| register_account user_id }
  end

  def unregister_users(*users)
    users.each { |user_id| delete_account user_id }
  end

  # appointment creation

  def register_creator
    create_appointment_args
    register_users creator
  end

  def register_all
    create_appointment_args
    register_creator
    register_users(*invitees)
  end

  def create_appointment_args
    @create_appointment_args ||= [
      'lysann.kessler@gmail.com',
      Meet4Xmas::Persistence::TravelType::ALL.first,
      Meet4Xmas::Persistence::Location.HPI.to_hash,
      [ 'test@example.com', 'foo@example.com' ],
      Meet4Xmas::Persistence::LocationType::ALL.first,
      'user message'
    ]
  end
  %w{creator travel_type location invitees location_type user_message}.each_with_index do |method, index|
    define_method method.to_sym do create_appointment_args[index] end
    define_method "set_#{method}".to_sym do |value| create_appointment_args[index] = value end
  end
  def participants
    invitees.clone.tap { |a| a << creator }
  end

  def create_appointment(*args)
    args = create_appointment_args if args.empty?
    @client.createAppointment(*args)
  end

  def get_appointment(appointment_id)
    @client.getAppointment(appointment_id)
  end

  # accepting / declining invitations

  def join_appointment(appointment_id, user_id, travel_type=Meet4Xmas::Persistence::TravelType::ALL.first, location=Meet4Xmas::Persistence::Location.HPI.to_hash)
    @client.joinAppointment(appointment_id, user_id, travel_type, location)
  end

  def decline_appointment(appointment_id, user_id)
    @client.declineAppointment(appointment_id, user_id)
  end

  def finalize_appointment(appointment_id)
    @client.finalizeAppointment(appointment_id)
  end

  # travel plan

  def get_travel_plan(appointment_id, travel_type=Meet4Xmas::Persistence::TravelType::ALL.first, location=Meet4Xmas::Persistence::Location.HPI.to_hash)
    @client.getTravelPlan(appointment_id, travel_type, location)
  end

  # handling responses

  def self._response_conssitent?(response)
    # must be a Hash
    return false unless response.kind_of?(Hash)
    # either successful and error is nil
    (response['success'] == true && response['error'] == nil) ||
    # or not successful and error is not nil and contains error information
    (response['success'] == false && response['error'] != nil &&
     response['error']['code'] != nil && response['error']['message'] != nil)
  end
end

#
# mocks
#

require 'rspec/mocks'

# mock google distance matrix api
class Meet4Xmas::WebAPI::GoogleDistanceMatrix
  def query_rows
    [{"elements"=>[{"distance"=>{"text"=>"25.5 km", "value"=>25490}, "duration"=>{"text"=>"22 mins", "value"=>1327}, "status"=>"OK"}, {"distance"=>{"text"=>"24.1 km", "value"=>24091}, "duration"=>{"text"=>"25 mins", "value"=>1500}, "status"=>"OK"}, {"distance"=>{"text"=>"22.2 km", "value"=>22233}, "duration"=>{"text"=>"23 mins", "value"=>1400}, "status"=>"OK"}, {"distance"=>{"text"=>"13.4 km", "value"=>13354}, "duration"=>{"text"=>"17 mins", "value"=>1038}, "status"=>"OK"}, {"distance"=>{"text"=>"25.0 km", "value"=>25018}, "duration"=>{"text"=>"23 mins", "value"=>1385}, "status"=>"OK"}, {"distance"=>{"text"=>"22.9 km", "value"=>22879}, "duration"=>{"text"=>"23 mins", "value"=>1364}, "status"=>"OK"}, {"distance"=>{"text"=>"18.7 km", "value"=>18686}, "duration"=>{"text"=>"19 mins", "value"=>1154}, "status"=>"OK"}, {"distance"=>{"text"=>"22.7 km", "value"=>22716}, "duration"=>{"text"=>"22 mins", "value"=>1331}, "status"=>"OK"}, {"distance"=>{"text"=>"22.6 km", "value"=>22566}, "duration"=>{"text"=>"20 mins", "value"=>1180}, "status"=>"OK"}, {"distance"=>{"text"=>"32.5 km", "value"=>32509}, "duration"=>{"text"=>"40 mins", "value"=>2396}, "status"=>"OK"}, {"distance"=>{"text"=>"33.8 km", "value"=>33776}, "duration"=>{"text"=>"41 mins", "value"=>2477}, "status"=>"OK"}, {"distance"=>{"text"=>"44.3 km", "value"=>44275}, "duration"=>{"text"=>"53 mins", "value"=>3159}, "status"=>"OK"}, {"distance"=>{"text"=>"42.9 km", "value"=>42931}, "duration"=>{"text"=>"51 mins", "value"=>3038}, "status"=>"OK"}, {"distance"=>{"text"=>"43.0 km", "value"=>42977}, "duration"=>{"text"=>"50 mins", "value"=>3004}, "status"=>"OK"}, {"distance"=>{"text"=>"40.7 km", "value"=>40749}, "duration"=>{"text"=>"48 mins", "value"=>2872}, "status"=>"OK"}, {"distance"=>{"text"=>"28.7 km", "value"=>28684}, "duration"=>{"text"=>"34 mins", "value"=>2013}, "status"=>"OK"}, {"distance"=>{"text"=>"25.2 km", "value"=>25245}, "duration"=>{"text"=>"30 mins", "value"=>1793}, "status"=>"OK"}, {"distance"=>{"text"=>"28.4 km", "value"=>28370}, "duration"=>{"text"=>"34 mins", "value"=>2035}, "status"=>"OK"}, {"distance"=>{"text"=>"30.4 km", "value"=>30368}, "duration"=>{"text"=>"32 mins", "value"=>1894}, "status"=>"OK"}, {"distance"=>{"text"=>"28.9 km", "value"=>28899}, "duration"=>{"text"=>"30 mins", "value"=>1784}, "status"=>"OK"}, {"distance"=>{"text"=>"29.4 km", "value"=>29367}, "duration"=>{"text"=>"31 mins", "value"=>1836}, "status"=>"OK"}, {"distance"=>{"text"=>"33.6 km", "value"=>33598}, "duration"=>{"text"=>"32 mins", "value"=>1898}, "status"=>"OK"}, {"distance"=>{"text"=>"28.4 km", "value"=>28373}, "duration"=>{"text"=>"27 mins", "value"=>1635}, "status"=>"OK"}, {"distance"=>{"text"=>"38.4 km", "value"=>38410}, "duration"=>{"text"=>"31 mins", "value"=>1853}, "status"=>"OK"}, {"distance"=>{"text"=>"38.4 km", "value"=>38410}, "duration"=>{"text"=>"31 mins", "value"=>1853}, "status"=>"OK"}, {"distance"=>{"text"=>"33.9 km", "value"=>33881}, "duration"=>{"text"=>"28 mins", "value"=>1659}, "status"=>"OK"}, {"distance"=>{"text"=>"35.8 km", "value"=>35771}, "duration"=>{"text"=>"31 mins", "value"=>1876}, "status"=>"OK"}, {"distance"=>{"text"=>"36.5 km", "value"=>36487}, "duration"=>{"text"=>"30 mins", "value"=>1826}, "status"=>"OK"}, {"distance"=>{"text"=>"33.6 km", "value"=>33616}, "duration"=>{"text"=>"27 mins", "value"=>1623}, "status"=>"OK"}, {"distance"=>{"text"=>"34.3 km", "value"=>34298}, "duration"=>{"text"=>"30 mins", "value"=>1775}, "status"=>"OK"}, {"distance"=>{"text"=>"39.7 km", "value"=>39701}, "duration"=>{"text"=>"32 mins", "value"=>1915}, "status"=>"OK"}, {"distance"=>{"text"=>"33.9 km", "value"=>33874}, "duration"=>{"text"=>"34 mins", "value"=>2052}, "status"=>"OK"}, {"distance"=>{"text"=>"32.2 km", "value"=>32190}, "duration"=>{"text"=>"35 mins", "value"=>2127}, "status"=>"OK"}, {"distance"=>{"text"=>"39.7 km", "value"=>39673}, "duration"=>{"text"=>"39 mins", "value"=>2356}, "status"=>"OK"}, {"distance"=>{"text"=>"33.8 km", "value"=>33795}, "duration"=>{"text"=>"33 mins", "value"=>1968}, "status"=>"OK"}, {"distance"=>{"text"=>"28.2 km", "value"=>28226}, "duration"=>{"text"=>"24 mins", "value"=>1437}, "status"=>"OK"}, {"distance"=>{"text"=>"30.8 km", "value"=>30789}, "duration"=>{"text"=>"26 mins", "value"=>1553}, "status"=>"OK"}, {"distance"=>{"text"=>"36.9 km", "value"=>36865}, "duration"=>{"text"=>"32 mins", "value"=>1890}, "status"=>"OK"}, {"distance"=>{"text"=>"36.9 km", "value"=>36869}, "duration"=>{"text"=>"32 mins", "value"=>1891}, "status"=>"OK"}, {"distance"=>{"text"=>"22.3 km", "value"=>22334}, "duration"=>{"text"=>"27 mins", "value"=>1630}, "status"=>"OK"}, {"distance"=>{"text"=>"23.2 km", "value"=>23178}, "duration"=>{"text"=>"28 mins", "value"=>1698}, "status"=>"OK"}, {"distance"=>{"text"=>"26.8 km", "value"=>26820}, "duration"=>{"text"=>"34 mins", "value"=>2017}, "status"=>"OK"}, {"distance"=>{"text"=>"28.9 km", "value"=>28887}, "duration"=>{"text"=>"27 mins", "value"=>1601}, "status"=>"OK"}, {"distance"=>{"text"=>"16.4 km", "value"=>16424}, "duration"=>{"text"=>"21 mins", "value"=>1271}, "status"=>"OK"}, {"distance"=>{"text"=>"18.6 km", "value"=>18584}, "duration"=>{"text"=>"25 mins", "value"=>1495}, "status"=>"OK"}, {"distance"=>{"text"=>"11.5 km", "value"=>11521}, "duration"=>{"text"=>"14 mins", "value"=>857}, "status"=>"OK"}, {"distance"=>{"text"=>"17.1 km", "value"=>17125}, "duration"=>{"text"=>"19 mins", "value"=>1124}, "status"=>"OK"}, {"distance"=>{"text"=>"13.1 km", "value"=>13070}, "duration"=>{"text"=>"15 mins", "value"=>914}, "status"=>"OK"}, {"distance"=>{"text"=>"8.8 km", "value"=>8810}, "duration"=>{"text"=>"11 mins", "value"=>668}, "status"=>"OK"}, {"distance"=>{"text"=>"13.7 km", "value"=>13696}, "duration"=>{"text"=>"16 mins", "value"=>986}, "status"=>"OK"}, {"distance"=>{"text"=>"28.9 km", "value"=>28915}, "duration"=>{"text"=>"33 mins", "value"=>1997}, "status"=>"OK"}, {"distance"=>{"text"=>"24.0 km", "value"=>23953}, "duration"=>{"text"=>"28 mins", "value"=>1661}, "status"=>"OK"}, {"distance"=>{"text"=>"24.2 km", "value"=>24176}, "duration"=>{"text"=>"28 mins", "value"=>1696}, "status"=>"OK"}, {"distance"=>{"text"=>"36.2 km", "value"=>36194}, "duration"=>{"text"=>"32 mins", "value"=>1893}, "status"=>"OK"}, {"distance"=>{"text"=>"24.2 km", "value"=>24217}, "duration"=>{"text"=>"28 mins", "value"=>1699}, "status"=>"OK"}, {"distance"=>{"text"=>"48.9 km", "value"=>48877}, "duration"=>{"text"=>"44 mins", "value"=>2645}, "status"=>"OK"}, {"distance"=>{"text"=>"47.1 km", "value"=>47122}, "duration"=>{"text"=>"40 mins", "value"=>2377}, "status"=>"OK"}, {"distance"=>{"text"=>"35.7 km", "value"=>35686}, "duration"=>{"text"=>"29 mins", "value"=>1714}, "status"=>"OK"}, {"distance"=>{"text"=>"49.6 km", "value"=>49577}, "duration"=>{"text"=>"45 mins", "value"=>2729}, "status"=>"OK"}, {"distance"=>{"text"=>"40.0 km", "value"=>39966}, "duration"=>{"text"=>"35 mins", "value"=>2107}, "status"=>"OK"}, {"distance"=>{"text"=>"44.9 km", "value"=>44904}, "duration"=>{"text"=>"37 mins", "value"=>2193}, "status"=>"OK"}, {"distance"=>{"text"=>"135 km", "value"=>135123}, "duration"=>{"text"=>"1 hour 30 mins", "value"=>5381}, "status"=>"OK"}, {"distance"=>{"text"=>"86.6 km", "value"=>86643}, "duration"=>{"text"=>"1 hour 0 mins", "value"=>3627}, "status"=>"OK"}, {"distance"=>{"text"=>"81.7 km", "value"=>81711}, "duration"=>{"text"=>"55 mins", "value"=>3306}, "status"=>"OK"}, {"distance"=>{"text"=>"59.2 km", "value"=>59170}, "duration"=>{"text"=>"43 mins", "value"=>2556}, "status"=>"OK"}, {"distance"=>{"text"=>"132 km", "value"=>132030}, "duration"=>{"text"=>"1 hour 28 mins", "value"=>5298}, "status"=>"OK"}, {"distance"=>{"text"=>"109 km", "value"=>108678}, "duration"=>{"text"=>"1 hour 11 mins", "value"=>4234}, "status"=>"OK"}, {"distance"=>{"text"=>"28.6 km", "value"=>28554}, "duration"=>{"text"=>"37 mins", "value"=>2230}, "status"=>"OK"}, {"distance"=>{"text"=>"121 km", "value"=>120870}, "duration"=>{"text"=>"1 hour 19 mins", "value"=>4710}, "status"=>"OK"}, {"distance"=>{"text"=>"39.8 km", "value"=>39764}, "duration"=>{"text"=>"35 mins", "value"=>2101}, "status"=>"OK"}, {"distance"=>{"text"=>"66.6 km", "value"=>66620}, "duration"=>{"text"=>"59 mins", "value"=>3551}, "status"=>"OK"}, {"distance"=>{"text"=>"31.8 km", "value"=>31773}, "duration"=>{"text"=>"40 mins", "value"=>2414}, "status"=>"OK"}, {"distance"=>{"text"=>"59.2 km", "value"=>59172}, "duration"=>{"text"=>"43 mins", "value"=>2584}, "status"=>"OK"}, {"distance"=>{"text"=>"54.7 km", "value"=>54685}, "duration"=>{"text"=>"38 mins", "value"=>2308}, "status"=>"OK"}, {"distance"=>{"text"=>"63.1 km", "value"=>63142}, "duration"=>{"text"=>"59 mins", "value"=>3555}, "status"=>"OK"}, {"distance"=>{"text"=>"75.6 km", "value"=>75636}, "duration"=>{"text"=>"57 mins", "value"=>3436}, "status"=>"OK"}, {"distance"=>{"text"=>"49.3 km", "value"=>49335}, "duration"=>{"text"=>"47 mins", "value"=>2841}, "status"=>"OK"}, {"distance"=>{"text"=>"118 km", "value"=>118192}, "duration"=>{"text"=>"1 hour 31 mins", "value"=>5489}, "status"=>"OK"}, {"distance"=>{"text"=>"115 km", "value"=>114777}, "duration"=>{"text"=>"1 hour 17 mins", "value"=>4599}, "status"=>"OK"}, {"distance"=>{"text"=>"36.4 km", "value"=>36381}, "duration"=>{"text"=>"35 mins", "value"=>2109}, "status"=>"OK"}, {"distance"=>{"text"=>"37.4 km", "value"=>37363}, "duration"=>{"text"=>"36 mins", "value"=>2146}, "status"=>"OK"}, {"distance"=>{"text"=>"80.6 km", "value"=>80578}, "duration"=>{"text"=>"1 hour 0 mins", "value"=>3570}, "status"=>"OK"}, {"distance"=>{"text"=>"147 km", "value"=>147419}, "duration"=>{"text"=>"1 hour 41 mins", "value"=>6085}, "status"=>"OK"}, {"distance"=>{"text"=>"80.8 km", "value"=>80831}, "duration"=>{"text"=>"1 hour 13 mins", "value"=>4409}, "status"=>"OK"}, {"distance"=>{"text"=>"53.8 km", "value"=>53776}, "duration"=>{"text"=>"41 mins", "value"=>2460}, "status"=>"OK"}, {"distance"=>{"text"=>"5.9 km", "value"=>5870}, "duration"=>{"text"=>"9 mins", "value"=>515}, "status"=>"OK"}, {"distance"=>{"text"=>"6.6 km", "value"=>6571}, "duration"=>{"text"=>"12 mins", "value"=>719}, "status"=>"OK"}, {"distance"=>{"text"=>"3.0 km", "value"=>3025}, "duration"=>{"text"=>"6 mins", "value"=>361}, "status"=>"OK"}, {"distance"=>{"text"=>"9.6 km", "value"=>9621}, "duration"=>{"text"=>"15 mins", "value"=>905}, "status"=>"OK"}, {"distance"=>{"text"=>"5.8 km", "value"=>5785}, "duration"=>{"text"=>"10 mins", "value"=>602}, "status"=>"OK"}, {"distance"=>{"text"=>"5.7 km", "value"=>5731}, "duration"=>{"text"=>"10 mins", "value"=>627}, "status"=>"OK"}, {"distance"=>{"text"=>"71.0 km", "value"=>71036}, "duration"=>{"text"=>"46 mins", "value"=>2765}, "status"=>"OK"}, {"distance"=>{"text"=>"12.7 km", "value"=>12654}, "duration"=>{"text"=>"19 mins", "value"=>1148}, "status"=>"OK"}, {"distance"=>{"text"=>"16.3 km", "value"=>16304}, "duration"=>{"text"=>"22 mins", "value"=>1298}, "status"=>"OK"}, {"distance"=>{"text"=>"170 km", "value"=>169960}, "duration"=>{"text"=>"2 hours 5 mins", "value"=>7515}, "status"=>"OK"}, {"distance"=>{"text"=>"57.7 km", "value"=>57694}, "duration"=>{"text"=>"44 mins", "value"=>2613}, "status"=>"OK"}]}]
  end
end

#
# custom matchers for response objects
#

require 'rspec/expectations'

RSpec::Matchers.define :be_successful do
  match_for_should do |response|
    Helpers._response_conssitent?(response) && response['success'] == true
  end
  match_for_should_not do |response|
    Helpers._response_conssitent?(response) && response['success'] == false
  end
  description do
    "be successful"
  end
end

RSpec::Matchers.define :return_error do |expected_code|
  match_for_should do |response|
    Helpers._response_conssitent?(response) && response['success'] == false && response['error']['code'] == expected_code
  end
  match_for_should_not do |response|
    (Helpers._response_conssitent?(response) && response['success'] == true) ||
    (Helpers._response_conssitent?(response) && response['success'] == false && response['error']['code'] != expected_code)
  end
  description do
    "return error #{expected_code}"
  end
end

#
# global setup & teardown routines
#

# for resetting DB
require 'rubygems'
require 'dm-core'

require 'rspec/core'
RSpec.configure do |config|
  config.include Helpers
  config.extend Helpers

  # server setup & teardown
  config.before :all do
    _start_server
  end
  config.after :all do
    _stop_server
  end

  # client setup
  config.before :all do
    _connect
  end

  # clean up database before each test
  config.before :each do
    _cleanup_db
  end
end
