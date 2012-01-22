# this is in an own file, so ruby does this for us only once
require 'java'
$CLASSPATH << File.expand_path('..', __FILE__)

module Java
  module Wire
    java_import   'org.meet4xmas.wire.Appointment'
    java_import   'org.meet4xmas.wire.ErrorInfo'
    java_import   'org.meet4xmas.wire.Location'
    java_import   'org.meet4xmas.wire.Participant'
    java_import   'org.meet4xmas.wire.Response'
    java_import   'org.meet4xmas.wire.TravelPlan'
  end
end
