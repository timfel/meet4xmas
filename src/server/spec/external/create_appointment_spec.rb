require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe '#deleteAccount' do
    def register_users(*users)
      users.each { |user| @client.registerAccount(user) }
    end
    def unregister_users(*users)
      users.each { |user| @client.deleteAccount(user) }
    end

    before :each do
      @creator = 'lysann.kessler@gmail.com'
      @invitees = [ 'test@example.com', 'foo@example.com' ]
      @location = Meet4Xmas::Persistence::Location.HPI
      @create_appointment_args = [
        @creator, Meet4Xmas::Persistence::TravelType::ALL.first, @location.to_hash,
        @invitees,
        Meet4Xmas::Persistence::LocationType::ALL.first,
        'user message'
      ]

      register_users @creator
      register_users(*@invitees)
    end

    it 'succeeds if everything is alright' do
      @client.createAppointment(*@create_appointment_args).should be_successful
    end

    it 'returns the appointment id' do
      payload = @client.createAppointment(*@create_appointment_args)['payload']
      payload.should be_kind_of(Numeric)
    end

    it 'can create multiple appointments' do
      @client.createAppointment(*@create_appointment_args).should be_successful
      @client.createAppointment(*@create_appointment_args).should be_successful
    end

    it 'returns different appointment ids for different appointments' do
      id1 = @client.createAppointment(*@create_appointment_args)['payload']
      id2 = @client.createAppointment(*@create_appointment_args)['payload']
      id1.should_not == id2
    end

    it 'fails if the creator is not registered' do
      unregister_users @creator
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if at least one invitee is not registered' do
      unregister_users @invitees.first
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the creator id is missing' do
      @create_appointment_args[0] = nil
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the travel type is invalid' do
      @create_appointment_args[1] = Meet4Xmas::Persistence::TravelType::ALL.reduce(:+) + 1
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the location is missing' do
      @create_appointment_args[2] = nil
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'succeeds if there are no invitees' do
      unregister_users(*@invitees) # optional for this test
      @create_appointment_args[3] = []
      response = @client.createAppointment(*@create_appointment_args)
      response.should be_successful
    end

    it 'fails if the location type is invalid' do
      @create_appointment_args[4] = Meet4Xmas::Persistence::LocationType::ALL.reduce(:+) + 1
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'succeeds if the user message is missing' do
      @create_appointment_args[5] = nil
      response = @client.createAppointment(*@create_appointment_args)
      response.should be_successful
    end

    describe 'validates the location: it' do
      { 'latitude'  => { 'valid_values' => [0, 5, -17, 90, -90], 'invalid_values' => [90.1, -90.1, -420, 180] },
        'longitude' => { 'valid_values' => [0, 90.1, -17, 42.7, 180, -180], 'invalid_values' => [180.1, -180.1, -420, 1000] }
      }.each do |key, values|
        values['valid_values'].each do |value|
          it "succeeds if location #{key} is valid (#{value})" do
            location = @create_appointment_args[2]
            location[key] = value
            @client.createAppointment(*@create_appointment_args).should be_successful
          end
        end
        values['invalid_values'].each do |value|
          it "fails if location #{key} is invalid (#{value})" do
            location = @create_appointment_args[2]
            location[key] = value
            response = @client.createAppointment(*@create_appointment_args)
            response.should_not be_successful
            # TODO: test error code
          end
        end
      end

      it 'succeeds if location title and description are missing' do
        location = @create_appointment_args[2]
        location.delete('title')
        location.delete('description')
        @client.createAppointment(*@create_appointment_args).should be_successful
      end
    end
  end
end
