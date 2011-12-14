require 'rubygems'
require 'dm-core'

module Meet4Xmas
module Persistence
  class Location
    include DataMapper::Resource

    property :id, Serial, :key => true

    property :latitude, Float, :required => true
    property :longitude, Float, :required => true
    property :title, String
    property :description, String
  end
end
end
