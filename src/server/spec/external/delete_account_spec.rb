require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe '#deleteAccount' do
    before :each do
      @user_id = 'lysann.kessler@gmail.com'
    end
    
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
