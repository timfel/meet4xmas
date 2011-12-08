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

  java_import   'lib.java.Servlet'
end

class Appointment
  include Java::Appointment

  def id
    0
  end

  def locationType
    0 # -> xmas market
  end

  def Location location
  end

  def invitees
    [] # user_id's
  end

  def participants
    [] # user_id's
  end
end

class Location
  include Java::Location

  def lng
    13.13175
  end

  def lat
    52.39363
  end

  def title
    "Hasso-Plattner-Institut"
  end

  def description
    "Campus Griebnitzsee, Prof.-Dr.-Helmert-Straße 2, 14482 Potsdam, Germany"
  end
end

class TravelPlan
  include Java::TravelPlan

  def appointmentId
    0
  end

  def path
    [] # locations
  end

  def travelType
    0 # -> 0 = car, 1 = by foot, 2 = public transportation
  end
end

class Servlet < Java::HessianServlet
  include Java::Servlet

  def registerAccount(userId)
    0
  end

  def createAppointment(userId, travelType, location, invitees, locationType, userMessage)
    0
  end

  def getAppointment(appointmentId)
    Appointment.new
  end

  def getTravelPlan(appointmentId, travelType, location)
    TravelPlan.new
  end

  def joinAppointment(appointmentId, userId, travelType, location)
    TravelPlan.new
  end

  def declineAppointment(appointmentId, userId, userMessage)
    0
  end

  def finalizeAppointment(appointmentId)
    0
  end
end

def init_jetty
  server = Java::Server.new(4567)
  context = Java::Context.new(server, '/', 0)
  servlet = Servlet.new
  holder = Java::ServletHolder.new servlet
  context.addServlet(holder, '/')
  server.start()
end
init_jetty
