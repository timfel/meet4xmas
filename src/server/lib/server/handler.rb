# load the wire classes
require File.expand_path('../../java/init', __FILE__)
require 'lib/persistence/setup' # requires all models

module Meet4Xmas
module Server
  class ServletHandler
    def registerAccount(userId, notificationServiceInfo)
      _transaction do |t|
        # get existing user
        user = Persistence::User.first :id => userId
        if user
          new_user = false
        else
          new_user = true
          # create new user
          user = Persistence::User.new :id => userId
        end

        # make sure the user is saved
        if user.save
          if notificationServiceInfo
            # add notification service information to the user
            user.update_notification_services(
              String.from_java_bytes(notificationServiceInfo.deviceId),
              notificationServiceInfo.serviceType
            )
          end

          # save and return
          if user.save
            if new_user
              payload = nil
            else
              # special: if the user already existed, return all his appointment ids
              payload = user.appointments.map(&:id)
            end
            # return result
            _success_response payload
          else
            _rollback_and_return_error(t, 0, "Unknown error while creating account")
          end
        else
          _rollback_and_return_error(t, 0, "Unknown error while creating account")
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
          location = Persistence::Location.from_java(java_location)

          #XXX: create users which not yet exist, we should send them mails later
          invitees.each do |invitee|
            Persistence::User.first_or_create(:id => invitee).save
          end

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

      _success_response(appointment.to_java)
    end

    def getTravelPlan(appointmentId, travelType, java_location)
      appointment = Persistence::Appointment.first(:id => appointmentId)
      return _error_response(0, "Appointment #{appointmentId} does not exist") unless appointment

      plan = Java::Wire::TravelPlan.new.tap do |java_plan|
        java_plan.path = appointment.travel_plan(travelType, Persistence::Location.from_java(java_location)).map(&:to_java)
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
            location = Persistence::Location.from_java java_location

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
        error_info = Java::Wire::ErrorInfo.new.tap do |info|
          info.code = error_info[:code]
          info.message = error_info[:message]
        end
      end
      Java::Wire::Response.new.tap do |response|
        response.success = success
        response.error   = error_info
        response.payload = payload
      end
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
