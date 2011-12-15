require File.expand_path('../service_spec_helper', __FILE__)
require 'set'

describe 'Meet4Xmas Service' do
  describe '#getAppointment' do
    def register_users(*users)
      users.each { |user| @client.registerAccount(user) }
    end
    
    before :each do
      # create an appointment
      @creator = 'lysann.kessler@gmail.com'
      invitees = [ 'test@example.com', 'foo@example.com' ]
      location = { 'longitude' => 0, 'latitude' => 0, 'title' => 'title', 'description' => 'description' }
      @location_type = Meet4Xmas::Persistence::LocationType::ALL.first
      @user_message = 'user message'
      create_appointment_args = [
        @creator, Meet4Xmas::Persistence::TravelType::ALL.first, location,
        invitees,
        @location_type,
        @user_message
      ]
      register_users @creator
      register_users *invitees
      @appointment_id = @client.createAppointment(*create_appointment_args)['payload']
      @participants = [] + invitees; @participants << @creator
    end

    it 'succeeds if the appointment exists' do
      @client.getAppointment(@appointment_id).should be_successful
    end

    it 'fails if the appointment does not exist' do
      response = @client.getAppointment(@appointment_id+1)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'returns the requested appointment' do
      payload = @client.getAppointment(@appointment_id)['payload']
      payload['identifier'].should == @appointment_id
    end

    describe 'returns' do
      before :each do
        @payload = @client.getAppointment(@appointment_id)['payload']
      end

      it 'the requested appointment' do
        @payload['identifier'].should == @appointment_id
      end

      it 'all attributes' do # TODO: split this test into subtests
        @payload['creator'].should == @creator
        @payload['locationType'].should == @location_type
        #@payload['location'].should_not be_nil # TODO
        @payload['isFinal'].should == false
        @payload['message'].should == @user_message

        returned_participants = @payload['participants']
        returned_participants.should be_kind_of(Array)
        returned_participants.count.should == @participants.count
        returned_participant_ids = returned_participants.map { |p| p['userId'] }
        Set.new(returned_participant_ids).should == Set.new(@participants)

        # the following two checks are actually more like lifecycle checks...
        creator_participant = returned_participants.find { |p| p['userId'] == @creator }
        creator_participant['status'].should == Meet4Xmas::Persistence::ParticipationStatus::Accepted

        invited_participants = returned_participants.select { |p| p['userId'] != @creator }
        invited_participants.each { |p| p['status'].should == Meet4Xmas::Persistence::ParticipationStatus::Pending }
      end
    end
  end
end
