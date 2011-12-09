require 'rubygems'
require 'dm-core'
require 'dm-migrations'

# load models
require File.expand_path('../user', __FILE__)

# open the database
module Persistence
  DB_FILE = File.expand_path('../meet4xmas.sqlite', __FILE__)
end
DataMapper.setup(:default, "sqlite3://#{Persistence::DB_FILE}")
DataMapper.finalize

# create/update the tables
DataMapper.auto_upgrade!

# some configurations
DataMapper::Model.raise_on_save_failure = true
