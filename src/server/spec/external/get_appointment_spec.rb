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
        @appointment = @client.getAppointment(@appointment_id)['payload']
      end

      it 'the requested appointment' do
        @appointment['identifier'].should == @appointment_id
      end

      { 'creator' => 'lysann.kessler@gmail.com',
        'locationType' => Meet4Xmas::Persistence::LocationType::ALL.first,
        #'location' => nil # TODO
        'message' => 'user message'
      }.each do |key, value|
        it "the #{key}" do @appointment[key].should == value end
      end

      it 'the participants (all invitees and the creator)' do
        returned_participants = @appointment['participants']
        returned_participant_ids = returned_participants.map { |p| p['userId'] }
        Set.new(returned_participant_ids).should == Set.new(@participants)
      end

      it 'some final state' do
        [true, false].should include(@appointment['isFinal'])
      end

      it 'participant states' do
        returned_participants = @appointment['participants']
        returned_participants.each do |p|
          Meet4Xmas::Persistence::ParticipationStatus::ALL.should include(p['status'])
        end
      end
    end
  end
end
