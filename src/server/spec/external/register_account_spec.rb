require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe '#registerAccount' do
    before :each do
      @user_id = 'lysann.kessler@gmail.com'
    end

    it 'succeeds if the account does not exist yet' do
      @client.registerAccount(@user_id).should be_successful
    end

    it 'succeeds if the account does not exist anymore' do
      @client.registerAccount(@user_id)
      @client.deleteAccount(@user_id)
      @client.registerAccount(@user_id).should be_successful
    end

    it 'succeeds if the account already exists' do
      @client.registerAccount(@user_id)
      @client.registerAccount(@user_id).should be_successful
    end

    it 'fails if the account id is not an email address' do
      @user_id = 'lysann.kessler'
      response = @client.registerAccount(@user_id)
      response.should_not be_successful
      # TODO: test error code
    end
  end
end
