require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

# require all models
Dir.glob(File.dirname(__FILE__) + '/*.rb', &method(:require))

# require the WebAPI
require File.join File.dirname(__FILE__), '..', 'webapi', 'setup'

# debugging options
DataMapper::Logger.new(STDERR, :debug) unless $MEET4XMAS_NO_DB_LOGGING

# open the database
module Meet4Xmas
module Persistence
  CONFIG_FILE = File.expand_path("../../../config/database.yml", __FILE__)
  CONFIG = File.exist?(CONFIG_FILE) ? YAML.load_file(CONFIG_FILE) : {}
  DB_FILE ||= (CONFIG["DB_FILE"] || 'sqlite3://' + File.expand_path('../meet4xmas.sqlite', __FILE__))
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
DataMapper.setup(Meet4Xmas::Persistence::REPOSITORY_NAME, Meet4Xmas::Persistence::DB_FILE)

# create/update the tables
DataMapper.finalize
DataMapper.auto_upgrade!
