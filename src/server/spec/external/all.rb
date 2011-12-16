require 'rspec/core'

require File.expand_path('../register_account_spec', __FILE__)
require File.expand_path('../delete_account_spec', __FILE__)
require File.expand_path('../create_appointment_spec', __FILE__)
require File.expand_path('../get_appointment_spec', __FILE__)
require File.expand_path('../appointment_lifecycle_spec', __FILE__)

RSpec::Core::Runner.run([])
