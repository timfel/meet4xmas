require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe 'appointment lifecycle.' do
    def register_users(*users)
      users.each { |user| @client.registerAccount(user) }
    end

    def create_appointment
      @creator = 'lysann.kessler@gmail.com'
      @invitees = [ 'test@example.com', 'foo@example.com' ]
      @participants = [] + @invitees; @participants << @creator
      location = Meet4Xmas::Persistence::Location.HPI
      @location_type = Meet4Xmas::Persistence::LocationType::ALL.first
      @user_message = 'user message'

      create_appointment_args = [
        @creator, Meet4Xmas::Persistence::TravelType::ALL.first, location.to_hash,
        @invitees,
        @location_type,
        @user_message
      ]

      register_users @creator
      register_users(*@invitees)
      @appointment_id = @client.createAppointment(*create_appointment_args)['payload']
    end

    def get_appointment(id)
      @client.getAppointment(id)
    end

    def try_join
      location = { 'longitude' => 1, 'latitude' => 0 }
      travel_type = Meet4Xmas::Persistence::TravelType::ALL.first
      response = @client.joinAppointment(@appointment_id, @invitees.first, travel_type, location)
    end

    def try_decline
      response = @client.declineAppointment(@appointment_id, @invitees.first)
    end

    it 'In the beginning there is no appointment' do
      (0..2).each { |i| get_appointment(i).should_not be_successful }
    end

    describe 'Right after creation' do
      before :each do
        id = create_appointment
        @appointment = get_appointment(id)['payload']
      end

      it 'the appointment is not final' do
        @appointment['isFinal'].should == false
      end

      it 'the creator is in "Accepted" state' do
        returned_participants = @appointment['participants']
        creator_participant = returned_participants.find { |p| p['userId'] == @creator }
        creator_participant['status'].should == Meet4Xmas::Persistence::ParticipationStatus::Accepted
      end

      it 'all invitees are in "Pending" state' do
        returned_participants = @appointment['participants']
        invited_participants = returned_participants.select { |p| p['userId'] != @creator }
        invited_participants.each { |p| p['status'].should == Meet4Xmas::Persistence::ParticipationStatus::Pending }
      end

      it 'invitees can join' do
        try_join.should be_successful
      end

      it 'invitees can decline' do
        try_decline.should be_successful
      end
    end

    describe 'After finalization' do
      before :each do
        id = create_appointment
        @client.finalizeAppointment(id)
        @appointment = get_appointment(id)['payload']
      end

      it 'the appointment is final' do
        @appointment['isFinal'].should == true
      end

      it 'travel plans do not change anymore' do
        pending
      end

      it 'joining still succeeds' do
        try_join.should be_successful
      end

      it 'declining still succeeds' do
        try_decline.should be_successful
      end
    end
  end
end
