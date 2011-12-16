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
  # server setup & teardown
  config.before :all do
    # start server
    @_port = 4568
    @_server = Meet4Xmas::Server::run @_port
  end
  config.after :all do
    # stop server
    @_server.stop
  end

  # client setup
  config.before :all do
    # initialize client
    @_address = "http://localhost:#{@_port}/#{Meet4Xmas::Server::API::VERSION}/"
    @client = Hessian::HessianClient.new(@_address)
  end

  # clean up database before each test
  config.before(:each) do
    DataMapper.auto_migrate!
  end
end
