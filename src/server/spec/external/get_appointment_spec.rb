require File.expand_path('../service_spec_helper', __FILE__)

describe 'Meet4Xmas Service' do
  describe '#getAppointment' do
    def register_users(*users)
      users.each { |user| @client.registerAccount(user) }
    end
    
    before :each do
      # create an appointment
      creator = 'lysann.kessler@gmail.com'
      invitees = [ 'test@example.com', 'foo@example.com' ]
      location = { 'longitude' => 0, 'latitude' => 0, 'title' => 'title', 'description' => 'description' }
      create_appointment_args = [
        creator, Meet4Xmas::Persistence::TravelType::ALL.first, location,
        invitees,
        Meet4Xmas::Persistence::LocationType::ALL.first,
        'user message'
      ]
      register_users creator
      register_users *invitees
      @appointment_id = @client.createAppointment(*create_appointment_args)['payload']
    end

    it 'succeeds if the appointment exists' do
      @client.getAppointment(@appointment_id).should be_successful
    end

    it 'fails if the appointment does not exist' do
      response = @client.getAppointment(@appointment_id+1)
      response.should_not be_successful
      # TODO: test error code
    end
  end
end
