# load the wire classes
require File.expand_path('../../java/init', __FILE__)
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

require 'lib/persistence/setup' # requires all models

module Meet4Xmas
module Server
  class ServletHandler
    def registerAccount(userId)
      _transaction do |t|
        user = Persistence::User.first(:id => userId)
        if user
          _success_response(user.appointments.map { |a| a.id })
        else
          user = Persistence::User.new :id => userId
          if user.save
            _success_response()
          else
            _rollback_and_return_error(t, 0, "Unknown error while creating account")
          end
        end
      end
    end

    def deleteAccount(userId)
      _transaction do |t|
        user = Persistence::User.first(:id => userId)
        if user
          if user.destroy()
            _success_response()
          else
            _rollback_and_return_error(t, 0, "Unknown error deleting account")
          end
        else
          _rollback_and_return_error(t, 0, "User '#{userId}' does not exist")
        end
      end
    end

    def createAppointment(userId, travelType, java_location, invitees, locationType, userMessage)
      return _error_response(0, "Missing parameter 'location'") unless java_location

      _transaction do |t|
        # fetch user
        user = Persistence::User.first(:id => userId)
        if user

          # build location object
          location = Persistence::Location.create({
            :latitude => java_location.latitude,
            :longitude => java_location.longitude,
            :title => java_location.title,
            :description => java_location.description
          })

          # create appointment
          appointment = user.create_appointment(travelType, location, invitees, locationType, userMessage)
          if appointment
            _success_response(appointment.id)
          else
            _rollback_and_return_error(t, 0, "Unknown error while creating appointment")
          end
        else
          _rollback_and_return_error(t, 0, "User '#{userId}' does not exist")
        end
      end
    end

    def getAppointment(appointmentId)
      appointment = Persistence::Appointment.first(:id => appointmentId)
      return _error_response(0, "Appointment #{appointmentId} does not exist") unless appointment

      result = Java::Wire::Appointment.new
      result.identifier = appointment.id
      result.creator = appointment.creator.id
      result.locationType = appointment.location_type
      #result.location = nil # TODO
      result.isFinal = appointment.is_final
      result.participants = appointment.participations.map do |participation|
        java_participant = Java::Wire::Participant.new
        java_participant.userId = participation.participant.id
        java_participant.status = participation.status
        java_participant
      end
      result.message = appointment.user_message
      _success_response(result)
    end

    def getTravelPlan(appointmentId, travelType, java_location)
      appointment = Persistence::Appointment.first(:id => appointmentId)
      return _error_response(0, "Appointment #{appointmentId} does not exist") unless appointment

      plan = Java::Wire::TravelPlan.new
      plan.path = appointment.travel_plan.map do |location|
        Java::Wire::Location.new.tap do |l|
          l.title = location.title
          l.description = location.description
          l.latitude = location.latitude
          l.longitude = location.longitude
        end
      end

      _success_response(plan)
    end

    def joinAppointment(appointmentId, userId, travelType, java_location)
      return _error_response(0, "Missing parameter 'location'") unless java_location

      _transaction do |t|
        # fetch user and appointment
        appointment = Persistence::Appointment.first(:id => appointmentId)
        if appointment
          user = Persistence::User.first(:id => userId)
          if user

            # build location object
            location = Persistence::Location.create({
              :latitude => java_location.latitude,
              :longitude => java_location.longitude,
              :title => java_location.title,
              :description => java_location.description
            })

            # join the appointment
            appointment.join(user, travelType, location)
            _success_response()
          else
            _rollback_and_return_error(t, 0, "User '#{userId}' does not exist")
          end
        else
          _rollback_and_return_error(t, 0, "Appointment #{appointmentId} does not exist")
        end
      end
    end

    def declineAppointment(appointmentId, userId)
      _transaction do |t|
        # fetch user and appointment
        appointment = Persistence::Appointment.first(:id => appointmentId)
        if appointment
          user = Persistence::User.first(:id => userId)
          if user

            # decline the appointment
            appointment.decline(user)
            _success_response()
          else
            _rollback_and_return_error(t, 0, "User '#{userId}' does not exist")
          end
        else
          _rollback_and_return_error(t, 0, "Appointment #{appointmentId} does not exist")
        end
      end
    end

    def finalizeAppointment(appointmentId)
      _transaction do |t|
        appointment = Persistence::Appointment.first(:id => appointmentId)
        if appointment
          appointment.finalize()
          _success_response()
        else
          _rollback_and_return_error(t, 0, "Appointment #{appointmentId} does not exist")
        end
      end
    end

    # transaction wrapper

    def _transaction(&block)
      Persistence.transaction &block
    end

    # responses

    def _build_response(success, error_info=nil, payload=nil)
      if error_info.kind_of?(Hash) && (error_info.has_key?(:code) || error_info.has_key?(:message))
        info = Java::Wire::ErrorInfo.new
        info.code = error_info[:code]
        info.message = error_info[:message]
        error_info = info
      end
      response = Java::Wire::Response.new
      response.success = success
      response.error = error_info
      response.payload = payload
      response
    end

    def _success_response(payload=nil)
      _build_response(true, nil, payload)
    end

    def _error_response(error_code, error_message)
      _build_response(false, {:code => error_code, :message => error_message})
    end

    def _rollback_and_return_error(transaction, error_code, error_message)
      transaction.rollback
      _error_response(error_code, error_message)
    end
  end
end
end