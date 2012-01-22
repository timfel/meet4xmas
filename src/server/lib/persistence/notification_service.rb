require 'rubygems'
require 'dm-core'
require 'dm-transactions'
require 'dm-validations'

module Meet4Xmas
  module Persistence
    class NotificationService
      include DataMapper::Resource

      property :id, Serial, :key => true
      property :device_id, Text, :required => true
      property :service_type, Integer, :required => true

      belongs_to :user, 'Meet4Xmas::Persistence::User'
    end
  end
end
