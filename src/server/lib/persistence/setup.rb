require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

# load models
require File.expand_path('../user', __FILE__)
require File.expand_path('../appointment', __FILE__)
require File.expand_path('../location', __FILE__)

# not a real model, but required to operate correctly
require File.expand_path('../enums', __FILE__)


# debugging options
DataMapper::Logger.new(STDOUT, :debug)

# open the database
module Persistence
  DB_FILE = File.expand_path('../meet4xmas.sqlite', __FILE__)
  REPOSITORY_NAME = :default

  def self.repository
    DataMapper.repository(REPOSITORY_NAME)
  end

  def self.transaction(&block)
    self.repository.transaction.commit(&block)
  end
end
DataMapper.setup(Persistence::REPOSITORY_NAME, "sqlite3://#{Persistence::DB_FILE}")

# create/update the tables
DataMapper.finalize
DataMapper.auto_upgrade!
