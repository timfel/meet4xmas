require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe '#deleteAccount' do
    before :each do
      @user_id = 'lysann.kessler@gmail.com'
    end

    it 'succeeds if the account exists' do
      register_account @user_id
      delete_account(@user_id).should be_successful
    end

    it 'fails if the account does not exist yet' do
      delete_account(@user_id).should return_error 0 # TODO: adjust error code
    end

    it 'fails if the account does not exist anymore' do
      register_account @user_id
      delete_account @user_id
      delete_account(@user_id).should return_error 0 # TODO: adjust error code
    end
  end
end
