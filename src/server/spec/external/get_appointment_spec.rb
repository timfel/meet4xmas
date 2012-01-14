require File.expand_path('../service_spec_helper', __FILE__)
require 'set'

describe 'Meet4Xmas Service' do
  describe '#getAppointment' do
    before :each do
      # create an appointment
      register_all
      @appointment_id = create_appointment['payload']
    end

    it 'succeeds if the appointment exists' do
      get_appointment(@appointment_id).should be_successful
    end

    it 'fails if the appointment does not exist' do
      get_appointment(@appointment_id+1).should return_error 0 # TODO: adjust error code
    end

    describe 'returns' do
      before :each do
        @appointment = get_appointment(@appointment_id)['payload']
      end

      it 'the requested appointment' do
        @appointment['identifier'].should == @appointment_id
      end

      { 'creator' => creator,
        'locationType' => location_type,
        'message' => user_message
      }.each do |key, value|
        it "the #{key}" do @appointment[key].should == value end
      end

      it 'the initial target location' do
        @appointment['location'].should == {
          "longitude"=>13.299218,
          "latitude"=>52.519812,
          "title"=>"Weihnachtsmarkt vor dem Schloss Charlottenburg",
          "description"=>"Spandauer Damm, 14059 Berlin"
        }
      end

      it 'the participants (all invitees and the creator)' do
        returned_participants = @appointment['participants']
        returned_participant_ids = returned_participants.map { |p| p['userId'] }
        Set.new(returned_participant_ids).should == Set.new(participants)
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
