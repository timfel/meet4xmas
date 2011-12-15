$MEET4XMAS_NO_LOGGING = true
$MEET4XMAS_DB_FILE_SUFFIX = '_test'

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

  # set some general fixture info
  before :each do
    @user_id = 'lysann.kessler@gmail.com'
  end

  describe '#registerAccount' do
    it 'succeeds if the account does not exist yet' do
      response = @client.registerAccount(@user_id)
      response.should be_successful
    end

    it 'succeeds if the account does not exist anymore' do
      @client.registerAccount(@user_id)
      @client.deleteAccount(@user_id)
      response = @client.registerAccount(@user_id)
      response.should be_successful
    end

    it 'fails if the account already exists' do
      @client.registerAccount(@user_id)
      response = @client.registerAccount(@user_id)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the account id is not an email address' do
      pending('need to check for account id format')
      @user_id = 'lysann.kessler'
      response = @client.registerAccount(@user_id)
      response.should_not be_successful
      # TODO: test error code
    end
  end

  describe '#deleteAccount' do
    it 'succeeds if the account exists' do
      @client.registerAccount(@user_id)
      response = @client.deleteAccount(@user_id)
      response.should be_successful
    end

    it 'fails if the account does not exist yet' do
      response = @client.deleteAccount(@user_id)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the account does not exist anymore' do
      @client.registerAccount(@user_id)
      @client.deleteAccount(@user_id)
      response = @client.deleteAccount(@user_id)
      response.should_not be_successful
      # TODO: test error code
    end
  end
end
