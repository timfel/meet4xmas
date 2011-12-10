require 'rubygems'
require 'dm-core'

module Persistence
  class User
    include DataMapper::Resource

    property :id, String, :key => true

end
