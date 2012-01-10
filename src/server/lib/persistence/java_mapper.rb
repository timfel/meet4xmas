module Meet4Xmas
module Persistence
	class Appointment
		def to_java
			Java::Wire::Appointment.new.tap do |java_appointment|
	      java_appointment.identifier   = self.id
	      java_appointment.creator      = self.creator.id
	      java_appointment.locationType = self.location_type
	      java_appointment.location     = self.location.to_java
	      java_appointment.isFinal      = self.is_final
	      java_appointment.participants = self.participations.map(&:to_java)
	      java_appointment.message      = self.user_message
	    end
		end
	end

  class Location
  	def to_java
  		Java::Wire::Location.new.tap do |java_location|
        java_location.title       = self.title
        java_location.description = self.description
        java_location.latitude    = self.latitude
        java_location.longitude   = self.longitude
      end
  	end

  	def self.from_java(java_location)
  		self.new.tap do |location|
  			location.title       = java_location.title
        location.description = java_location.description
        location.latitude    = java_location.latitude
        location.longitude   = java_location.longitude
  		end
  	end
  end

  class AppointmentParticipation
  	def to_java
  		Java::Wire::Participant.new.tap do |java_participant|
        java_participant.userId = self.participant.id
        java_participant.status = self.status
      end
  	end
  end
end
end
