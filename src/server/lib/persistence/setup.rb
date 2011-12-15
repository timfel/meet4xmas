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
DataMapper::Logger.new(STDERR, :debug) unless $MEET4XMAS_NO_LOGGING

# open the database
module Meet4Xmas
module Persistence
  DB_FILE = File.expand_path('../meet4xmas', __FILE__)
  DB_FILE_EXTENSION = '.sqlite'
  REPOSITORY_NAME = :default

  def self.repository
    DataMapper.repository(REPOSITORY_NAME)
  end

  def self.transaction(&block)
    self.repository.transaction.commit(&block)
  end

  def self.transient_transaction(&block)
  	transaction = self.repository.transaction
    begin
      transaction.begin
      rval = nil
      rval = transaction.within { |*block_args| yield(*block_args) }
    ensure
      transaction.rollback if transaction.begin?
      rval
    end
  end
end
end
suffix = $MEET4XMAS_DB_FILE_SUFFIX || ''
file_name = "sqlite3://#{Meet4Xmas::Persistence::DB_FILE}#{$MEET4XMAS_DB_FILE_SUFFIX}#{Meet4Xmas::Persistence::DB_FILE_EXTENSION}"
DataMapper.setup(Meet4Xmas::Persistence::REPOSITORY_NAME, file_name)

# create/update the tables
DataMapper.finalize
DataMapper.auto_upgrade!
