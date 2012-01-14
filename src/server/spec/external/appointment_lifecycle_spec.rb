require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe 'appointment lifecycle.' do
    def try_join
      join_appointment(@appointment_id, invitees.first)
    end
    def try_decline
      decline_appointment(@appointment_id, invitees.first)
    end

    it 'In the beginning there is no appointment' do
      (0..2).each { |i| get_appointment(i).should_not be_successful }
    end

    describe 'Right after creation' do
      before :each do
        register_creator
        @appointment_id = create_appointment['payload']
        @appointment = get_appointment(@appointment_id)['payload']
      end

      it 'the appointment is not final' do
        @appointment['isFinal'].should == false
      end

      it 'the creator is in "Accepted" state' do
        returned_participants = @appointment['participants']
        creator_participant = returned_participants.find { |p| p['userId'] == creator }
        creator_participant['status'].should == Meet4Xmas::Persistence::ParticipationStatus::Accepted
      end

      it 'all invitees are in "Pending" state' do
        returned_participants = @appointment['participants']
        invited_participants = returned_participants.select { |p| p['userId'] != creator }
        invited_participants.each { |p| p['status'].should == Meet4Xmas::Persistence::ParticipationStatus::Pending }
      end

      it 'invitees can join' do
        try_join.should be_successful
      end

      it 'invitees can decline' do
        try_decline.should be_successful
      end

      it 'give a nice travel plan' do
        location = { 'longitude' => 1, 'latitude' => 0 }
        travel_type = Meet4Xmas::Persistence::TravelType::ALL.first
        @client.getTravelPlan( @appointment_id, travel_type, location ).size.should >= 2
      end
    end

    describe 'After finalization' do
      before :each do
        register_creator
        @appointment_id = create_appointment['payload']
        finalize_appointment(@appointment_id)
        @appointment = get_appointment(@appointment_id)['payload']
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
