require File.expand_path('../service_spec_helper', __FILE__)
require 'set'

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

    describe 'response payload' do
      before :each do
        @client.registerAccount(@user_id)
        @response = @client.registerAccount(@user_id)
      end

      it 'is a list' do
        @response['payload'].should be_kind_of(Array)
      end

      it 'is empty if the user is new' do
        @response['payload'].should be_empty
      end

      it 'contains a list of appointment ids the user participates in' do
        @invitees = [ 'test@example.com', 'foo@example.com' ]
        @location = { 'longitude' => 0, 'latitude' => 0, 'title' => 'title', 'description' => 'description' }
        @create_appointment_args = [
          @user_id, Meet4Xmas::Persistence::TravelType::ALL.first, @location,
          @invitees,
          Meet4Xmas::Persistence::LocationType::ALL.first,
          'user message'
        ]
        @invitees.each { |user| @client.registerAccount(user) }

        ids = []
        ids << @client.createAppointment(*@create_appointment_args)['payload']
        ids << @client.createAppointment(*@create_appointment_args)['payload']

        returned_ids = @client.registerAccount(@user_id)['payload']
        Set.new(returned_ids).should == Set.new(ids)
      end
    end
  end
end
