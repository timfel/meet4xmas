$LOAD_PATH.unshift File.dirname(__FILE__)

require 'java'
require 'hessian'
require 'jetty'
require 'jetty-util'
require 'servlet-api'
require 'rubygems'
require 'geokit'

module Java
  include_class 'org.mortbay.jetty.Server'
  include_class 'org.mortbay.jetty.servlet.Context'
  include_class 'org.mortbay.jetty.servlet.ServletHolder'
  include_class 'com.caucho.hessian.server.HessianServlet'

  java_import   'lib.java.Appointment'
  java_import   'lib.java.Location'
  java_import   'lib.java.TravelPlan'
  java_import   'lib.java.ResponseBody'
  java_import   'lib.java.Servlet'
end

class ServletHandler
  def registerAccount(userId)
    _success_response()
  end

  def createAppointment(userId, travelType, location, invitees, locationType, userMessage)
    _error_response(42, 'error!')
  end

  def getAppointment(appointmentId)
    a = Java::Appointment.new
    a.identifier = appointmentId
    a.locationType = Java::Location::LocationType::ChristmasMarket
    a.invitees = ['foo']
    a.participants = ['bar']
    _success_response(a)
  end

  def getTravelPlan(appointmentId, travelType, location)
    _success_response(TravelPlan.new)
  end

  def joinAppointment(appointmentId, userId, travelType, location)
    _success_response(TravelPlan.new)
  end

  def declineAppointment(appointmentId, userId, userMessage)
    _success_response()
  end

  def finalizeAppointment(appointmentId)
    _success_response()
  end

  # responses

  def _build_response(success, error_info=nil, payload=nil)
    if error_info.kind_of?(Hash) && (error_info.has_key?(:code) || error_info.has_key?(:message))
      info = Java::ResponseBody::ErrorInfo.new
      info.code = error_info[:code]
      info.message = error_info[:message]
      error_info = info
    end
    response = Java::ResponseBody.new
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
end

class Servlet < Java::HessianServlet
  include Java::Servlet

  def initialize(*args, &block)
    super
    @handler = ServletHandler.new
  end

  %w(registerAccount createAppointment getAppointment getTravelPlan
     joinAppointment declineAppointment finalizeAppointment).each do |meth|
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
      response = @handler._error_response(0, e.to_s)
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
