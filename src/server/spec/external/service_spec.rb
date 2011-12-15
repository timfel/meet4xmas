require File.expand_path('../../../lib/server', __FILE__)
require File.expand_path('../../../lib/server/api', __FILE__)

require File.expand_path('../../../lib/hessian_client/lib/hessian', __FILE__)

require 'rubygems'
require 'dm-core'

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
      response['success'].should be_true
      response['error'].should be_nil
      response['payload'].should be_nil
    end
  end
end
