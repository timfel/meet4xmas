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
    DataMapper.auto_migrate!
  end

  # user registration

  def register_users(*users)
    users.each { |user| @client.registerAccount(user) }
  end

  def unregister_users(*users)
    users.each { |user| @client.deleteAccount(user) }
  end

  # appointment creation

  def register_all
    create_appointment_args
    register_users creator
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
  def creator
    create_appointment_args[0]
  end
  def travel_type
    create_appointment_args[1]
  end
  def location
    create_appointment_args[2]
  end
  def invitees
    create_appointment_args[3]
  end
  def location_type
    create_appointment_args[4]
  end
  def user_message
    create_appointment_args[5]
  end
  def participants
    invitees.clone.tap { |a| a << creator }
  end

  def create_appointment(*args)
    args = create_appointment_args if args.empty?
    @client.createAppointment(*args)
  end

  def get_appointment(id=@appointment_id)
    @client.getAppointment id
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
  config.before(:each) do
    _cleanup_db
  end
end
