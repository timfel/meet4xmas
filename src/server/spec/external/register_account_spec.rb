require File.expand_path('../service_spec_helper', __FILE__)
require 'set'

describe 'Meet4Xmas Service' do
  describe '#registerAccount' do
    before :each do
      @user_id = 'lysann.kessler@gmail.com'
    end

    it 'succeeds if the account does not exist yet' do
      register_account(@user_id).should be_successful
    end

    it 'succeeds if the account does not exist anymore' do
      register_account @user_id
      delete_account @user_id
      register_account(@user_id).should be_successful
    end

    it 'succeeds if the account already exists' do
      register_account @user_id
      register_account(@user_id).should be_successful
    end

    it 'fails if the account id is not an email address' do
      @user_id = 'lysann.kessler'
      register_account(@user_id).should return_error 0 # TODO: adjust error code
    end

    describe 'with notification service information' do
      before :each do
        @notification_service_info_apns = {
          'serviceType' => Meet4Xmas::Persistence::NotificationServiceType::APNS,
          'deviceId' => Hessian::Binary.new("38dede2764b83e4827600c970c154543ea02e5c6d0b86ab7cf569920c9e63f52".scan(/../).map{|b|b.to_i(16)}.pack('C*'))
        }
        @notification_service_info_apns2 = {
          'serviceType' => Meet4Xmas::Persistence::NotificationServiceType::APNS,
          'deviceId' => Hessian::Binary.new("855ab705fb240d8ba34b9c74831670c461592ef96b7f4ab17d521df33d29551f".scan(/../).map{|b|b.to_i(16)}.pack('C*'))
        }
        @notification_service_info_mpns = {
          'serviceType' => Meet4Xmas::Persistence::NotificationServiceType::MPNS,
          'deviceId' => Hessian::Binary.new("http://db3.notify.live.net/throttledthirdparty/01.00/AAHgDEhLQN9-Tq9OIXlhODkrAgAAAAADQAAAAAQUZm52OkJCMjg1QTg1QkZDMkUxREQ".unpack('U*'))
        }
      end

      it 'is optional' do
        register_account(@user_id, nil).should be_successful
      end

      it 'works if everything is alright' do
        register_account(@user_id, @notification_service_info_apns).should be_successful
      end

      it 'can register multiple services of the same service type' do
        register_account(@user_id, @notification_service_info_apns).should be_successful
        register_account(@user_id, @notification_service_info_apns2).should be_successful
      end

      it 'can register the same service multiple times' do
        register_account(@user_id, @notification_service_info_apns).should be_successful
        register_account(@user_id, @notification_service_info_apns).should be_successful
      end

      it 'can register multiple services of different service types' do
        register_account(@user_id, @notification_service_info_apns).should be_successful
        register_account(@user_id, @notification_service_info_mpns).should be_successful
      end
    end

    describe 'response payload' do
      describe '(if the user did not exists)' do
        it 'is nil' do
          register_account(@user_id)['payload'].should be_nil
        end
      end

      describe '(if the user did already exist)' do
        before :each do
          register_account @user_id
          @response = register_account @user_id
        end

        it 'is a list' do
          @response['payload'].should be_kind_of(Array)
        end

        it 'is empty if the user is new' do
          @response['payload'].should be_empty
        end

        it 'contains a list of appointment ids the user participates in' do
          # create some appointments for this user
          set_creator @user_id # make sure the user exists, as this is required by createAppointment
          ids = [ create_appointment['payload'], create_appointment['payload'] ]

          # invoke registerAccount
          returned_ids = register_account(@user_id)['payload']

          # check result
          Set.new(returned_ids).should == Set.new(ids)
        end
      end
    end
  end
end
