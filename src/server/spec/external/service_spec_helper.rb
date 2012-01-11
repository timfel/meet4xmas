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

  def register_all
    register_users @creator if defined?(@creator)
    register_users(*@invitees) if defined?(@invitees)
  end

  # appointment creation

  def create_appointment_args
    @creator ||= 'lysann.kessler@gmail.com'
    @invitees ||= [ 'test@example.com', 'foo@example.com' ]
    @location ||= Meet4Xmas::Persistence::Location.HPI
    @create_appointment_args ||= [
      @creator, Meet4Xmas::Persistence::TravelType::ALL.first, @location.to_hash,
      @invitees,
      Meet4Xmas::Persistence::LocationType::ALL.first,
      'user message'
    ]
  end

  def create_appointment(*args)
    args = create_appointment_args if args.empty?
    @client.createAppointment(*args)
  end
end

#
# custom matchers for response objects
#

require 'rspec/expectations'

RSpec::Matchers.define :be_successful do
  def consistent?(response)
    # must be a Hash
    return false unless response.kind_of?(Hash)
    # either successful and error is nil
    (response['success'] == true && response['error'] == nil) ||
    # or not successful and error is not nil and contains error information
    (response['success'] == false && response['error'] != nil &&
     response['error']['code'] != nil && response['error']['message'] != nil)
  end

  match_for_should do |response|
    consistent?(response) && response['success'] == true
  end
  match_for_should_not do |response|
    consistent?(response) && response['success'] == false
  end
  description do
    "be successful"
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
