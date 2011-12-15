# require server implementation & api info
require File.expand_path('../../../lib/server', __FILE__)
require File.expand_path('../../../lib/server/api', __FILE__)

# require hessian client
require File.expand_path('../../../lib/hessian_client/lib/hessian', __FILE__)

# for resetting DB
require 'rubygems'
require 'dm-core'

# custom matchers for response objects
require 'rspec/expectations'
RSpec::Matchers.define :be_successful do
  match_for_should do |response|
    response['success'] == true && response['error'] == nil
  end
  match_for_should_not do |response|
    response['success'] == false && response['error'] != nil &&
    response['error']['code'] != nil && response['error']['message'] != nil
  end
  description do
    "be successful"
  end
end

MEET4XMAS_TEST_PORT = 4568

describe 'Meet4Xmas Service' do
  # server setup & teardown
  before :all do
    # start server
    @_port = MEET4XMAS_TEST_PORT
    @_server = Meet4Xmas::Server::run @_port
  end
  after :all do
    # stop server
    @_server.stop
  end

  # client setup
  before :all do
    # initialize client
    @_address = "http://localhost:#{MEET4XMAS_TEST_PORT}/#{Meet4Xmas::Server::API::VERSION}/"
    @client = Hessian::HessianClient.new(@_address)
  end

  # clean up database before each test
  before :each do
    DataMapper.auto_migrate!
  end

  describe '#registerAccount' do
    it 'succeeds if the account does not exist yet' do
      response = @client.registerAccount('lysann.kessler@gmail.com')
      response.should be_successful
      response['payload'].should be_nil
    end
  end
end
