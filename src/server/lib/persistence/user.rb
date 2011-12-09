require 'rubygems'
require 'dm-core'

module Persistence

  class User
    include DataMapper::Resource

    property :identifier, String, :key => true
  end

end
