require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe '#deleteAccount' do
    before :each do
      @user_id = 'lysann.kessler@gmail.com'
    end
    
    def register_invitees
      @invitees.each { |invitee| @client.registerAccount(invitee) }
    end
    def register_creator
      @client.registerAccount(@creator)
    end

    before :each do
      @creator = 'lysann.kessler@gmail.com'
      @invitees = [ 'test@example.com', 'foo@example.com' ]
      @location = { 'longitude' => 0, 'latitude' => 0, 'title' => 'title', 'description' => 'description' }
      @create_appointment_args = [
        @creator, Meet4Xmas::Persistence::TravelType::ALL.first, @location,
        @invitees,
        Meet4Xmas::Persistence::LocationType::ALL.first,
        'user message'
      ]
    end

    it 'succeeds if everything is alright' do
      register_creator
      register_invitees
      response = @client.createAppointment(*@create_appointment_args)
      response.should be_successful
    end

    it 'returns the appointment id' do
      register_creator
      register_invitees
      response = @client.createAppointment(*@create_appointment_args)
      payload = response['payload']
      payload.should be_kind_of(Numeric)
    end

    it 'can create multiple appointments' do
      register_creator
      register_invitees
      response = @client.createAppointment(*@create_appointment_args)
      response.should be_successful
      response = @client.createAppointment(*@create_appointment_args)
      response.should be_successful
    end

    it 'returns subsequent appointment ids' do
      register_creator
      register_invitees
      id1 = @client.createAppointment(*@create_appointment_args)['payload']
      id2 = @client.createAppointment(*@create_appointment_args)['payload']
      id2.should == (id1+1)
    end

    it 'fails if the creator is not registered' do
      register_invitees
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if one invitee is not registered' do
      register_creator
      @invitees.take(@invitees.size - 1).each { |invitee| @client.registerAccount(invitee) }
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the creator id is missing' do
      register_creator
      register_invitees
      @create_appointment_args[0] = nil
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the travel type is invalid' do
      register_creator
      register_invitees
      @create_appointment_args[1] = Meet4Xmas::Persistence::TravelType::ALL.reduce(:+) + 1
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'fails if the location is missing' do
      register_creator
      register_invitees
      @create_appointment_args[2] = nil
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end

    it 'succeeds if there are no invitees' do
      register_creator
      @create_appointment_args[3] = []
      response = @client.createAppointment(*@create_appointment_args)
      response.should be_successful
    end

    it 'fails if the location type is invalid' do
      register_creator
      register_invitees
      @create_appointment_args[4] = Meet4Xmas::Persistence::LocationType::ALL.reduce(:+) + 1
      response = @client.createAppointment(*@create_appointment_args)
      response.should_not be_successful
      # TODO: test error code
    end
  end
end
