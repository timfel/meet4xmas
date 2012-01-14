require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe '#createAppointment' do
    before :each do
      create_appointment_args # load them so we can manipulate them later
      register_creator
    end

    it 'succeeds if everything is alright' do
      create_appointment.should be_successful
    end

    it 'returns the appointment id' do
      payload = create_appointment['payload']
      payload.should be_kind_of(Numeric)
    end

    it 'can create multiple appointments' do
      create_appointment.should be_successful
      create_appointment.should be_successful
    end

    it 'returns different appointment ids for different appointments' do
      id1 = create_appointment['payload']
      id2 = create_appointment['payload']
      id1.should_not == id2
    end

    it 'fails if the creator is not registered' do
      unregister_users creator
      create_appointment.should return_error(0) # TODO: adjust error code
    end

    it 'succeeds even if an invitee is not registered' do
      unregister_users invitees.first
      create_appointment.should be_successful
    end

    it 'fails if the creator id is missing' do
      set_creator nil
      create_appointment.should return_error(0) # TODO: adjust error code
    end

    it 'fails if the travel type is invalid' do
      set_travel_type Meet4Xmas::Persistence::TravelType::ALL.reduce(:+) + 1
      create_appointment.should return_error(0) # TODO: adjust error code
    end

    it 'fails if the location is missing' do
      set_location nil
      create_appointment.should return_error(0) # TODO: adjust error code
    end

    it 'succeeds if there are no invitees' do
      unregister_users(*invitees) # optional for this test
      set_invitees []
      create_appointment.should be_successful
    end

    it 'fails if the location type is invalid' do
      set_location_type Meet4Xmas::Persistence::LocationType::ALL.reduce(:+) + 1
      create_appointment.should return_error(0) # TODO: adjust error code
    end

    it 'succeeds if the user message is missing' do
      set_user_message nil
      create_appointment.should be_successful
    end

    describe 'validates the location: it' do
      { 'latitude'  => { 'valid_values' => [0, 5, -17, 90, -90], 'invalid_values' => [90.1, -90.1, -420, 180] },
        'longitude' => { 'valid_values' => [0, 90.1, -17, 42.7, 180, -180], 'invalid_values' => [180.1, -180.1, -420, 1000] }
      }.each do |key, values|
        values['valid_values'].each do |value|
          it "succeeds if location #{key} is valid (#{value})" do
            location[key] = value
            create_appointment.should be_successful
          end
        end
        values['invalid_values'].each do |value|
          it "fails if location #{key} is invalid (#{value})" do
            location[key] = value
            create_appointment.should return_error(0) # TODO: adjust error code
          end
        end
      end

      it 'succeeds if location title and description are missing' do
        location.delete('title')
        location.delete('description')
        create_appointment.should be_successful
      end
    end
  end
end
