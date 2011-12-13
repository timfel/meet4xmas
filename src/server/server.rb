$LOAD_PATH.unshift File.dirname(__FILE__)

require 'java'
require 'lib/java/hessian'
require 'lib/java/jetty'
require 'lib/java/jetty-util'
require 'lib/java/servlet-api'

require 'rubygems'
require 'geokit'

require 'lib/persistence/setup' # requires all models

module Java
  include_class 'org.mortbay.jetty.Server'
  include_class 'org.mortbay.jetty.servlet.Context'
  include_class 'org.mortbay.jetty.servlet.ServletHolder'
  include_class 'com.caucho.hessian.server.HessianServlet'

  module Wire
    $CLASSPATH << 'lib/java'
    java_import   'org.meet4xmas.wire.Appointment'
    java_import   'org.meet4xmas.wire.ErrorInfo'
    java_import   'org.meet4xmas.wire.IServiceAPI'
    java_import   'org.meet4xmas.wire.Location'
    java_import   'org.meet4xmas.wire.Participant'
    java_import   'org.meet4xmas.wire.Response'
    java_import   'org.meet4xmas.wire.TravelPlan'
  end
end

class ServletHandler
  def registerAccount(userId)
    Persistence.transaction do |t|
      user = Persistence::User.create :id => userId
      return _rollback_and_return_error(t, 0, "Unknown error while creating account") unless user
      _success_response()
    end
  end

  def deleteAccount(userId)
    Persistence.transaction do |t|
      user = Persistence::User.first(:id => userId)
      return _rollback_and_return_error(t, 0, "User '#{userId}' does not exist") unless user
      return _rollback_and_return_error(t, 0, "Unknown error deleting account") unless user.destroy()
      _success_response()
    end
  end

  def createAppointment(userId, travelType, java_location, invitees, locationType, userMessage)
    return _error_response(0, "Missing parameter 'location'") unless java_location

    Persistence.transaction do |t|
      # fetch user
      user = Persistence::User.first(:id => userId)
      return _rollback_and_return_error(t, 0, "User '#{userId}' does not exist") unless user

      # build location object
      location = Persistence::Location.create({
        :latitude => java_location.latitude,
        :longitude => java_location.longitude,
        :title => java_location.title,
        :description => java_location.description
      })

      # create appointment
      appointment = user.create_appointment(travelType, location, invitees, locationType, userMessage)
      return _rollback_and_return_error(t, 0, "Unknown error while creating appointment") unless appointment
      
      _success_response(appointment.id)
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
    plan.path = [] # TODO

    _success_response(plan)
  end

  def joinAppointment(appointmentId, userId, travelType, java_location)
    return _error_response(0, "Missing parameter 'location'") unless java_location

    Persistence.transaction do |t|
      # fetch user and appointment
      appointment = Persistence::Appointment.first(:id => appointmentId)
      return _rollback_and_return_error(t, 0, "Appointment #{appointmentId} does not exist") unless appointment
      user = Persistence::User.first(:id => userId)
      return _rollback_and_return_error(t, 0, "User '#{userId}' does not exist") unless user

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
    end
  end

  def declineAppointment(appointmentId, userId)
    Persistence.transaction do |t|
      appointment = Persistence::Appointment.first(:id => appointmentId)
      return _rollback_and_return_error(t, 0, "Appointment #{appointmentId} does not exist") unless appointment
      user = Persistence::User.first(:id => userId)
      return _rollback_and_return_error(t, 0, "User '#{userId}' does not exist") unless user

      appointment.decline(user)
      _success_response()
    end
  end

  def finalizeAppointment(appointmentId)
    Persistence.transaction do |t|
      appointment = Persistence::Appointment.first(:id => appointmentId)
      return _rollback_and_return_error(t, 0, "Appointment #{appointmentId} does not exist") unless appointment
      
      appointment.finalize()
      _success_response()
    end
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
    t.rollback
    x = _error_response(error_code, error_message)
    puts "result0: #{x}"
    x
  end
end

class Servlet < Java::HessianServlet
  include Java::Wire::IServiceAPI

  def initialize(*args, &block)
    super
    @handler = ServletHandler.new
  end

  ALL_MESSAGES = %w(registerAccount deleteAccount
    createAppointment getAppointment getTravelPlan
    joinAppointment declineAppointment finalizeAppointment)
  
  ALL_MESSAGES.each do |meth|
    define_method(meth) do |*args, &block|
      handle_servlet_action(meth, *args, &block)
    end
  end

  def handle_servlet_action(meth, *args, &block)
    begin
      puts "received: #{meth}(#{args_to_s(*args)})"
    rescue => e
      puts "error logging received operation: #{e}"
    end

    begin
      response = @handler.send(meth, *args, &block)
    rescue => e
      response = @handler._error_response(0, "#{e}\n  "+e.backtrace.join("\n  "))
    end
    
    begin
      puts "sending: #{response}"
    rescue => e
      puts "error logging response: #{e}"
    end
    response
  end

private
  
  def args_to_s(*args)
    args.map do |arg|
      case arg
      when nil
        "<null>"
      when String
        "'#{arg}'"
      else
        if arg.respond_to? :each
          "[#{args_to_s(*arg)}]"
        else
          arg
        end
      end
    end.join(', ')
  end
end

module Server
  API_VERSION = 1

  def self.init_jetty
    port = ARGV.first.to_i.to_s == ARGV.first.to_s ? ARGV.first.to_i : 4567
    server = Java::Server.new port
    context = Java::Context.new(server, '/', 0)
    servlet = Servlet.new
    holder = Java::ServletHolder.new servlet
    context.addServlet(holder, "/#{API_VERSION}/")
    server.start()
    puts "Server living at port #{port} - api version: #{API_VERSION}"
  end
end
Server::init_jetty
