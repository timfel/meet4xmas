require File.expand_path('../../../lib/server', __FILE__)
require File.expand_path('../../../lib/server/api', __FILE__)

require File.expand_path('../../../lib/hessian_client/lib/hessian', __FILE__)

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

  it "has tests" do
    pending "first implement a test!"
  end

  it "has even more tests" do
    pending "first implement any test!"
  end
end
