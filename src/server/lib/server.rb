# require some general API info
require File.expand_path('../server/api', __FILE__)

# require the jetty server and servlet API
require File.expand_path('../java/init', __FILE__)
require 'lib/java/jetty'
require 'lib/java/jetty-util'
require 'lib/java/servlet-api'
module Java
  module Jetty
    include_class 'org.mortbay.jetty.Server'
    include_class 'org.mortbay.jetty.servlet.Context'
    include_class 'org.mortbay.jetty.servlet.ServletHolder'
  end
end

# require our hessian servlet implementation
require File.expand_path('../server/servlet', __FILE__)

module Meet4Xmas
module Server
  API_VERSION = Server::API::VERSION

  def self.run(port = nil)
    port = 4567 if port == nil
    server = Java::Jetty::Server.new port
    context = Java::Jetty::Context.new(server, '/', 0)
    servlet = Servlet.new # our servlet implementation
    holder = Java::Jetty::ServletHolder.new servlet
    context.addServlet(holder, "/#{API_VERSION}/")
    server.start()
    return server
  end
end
end

if __FILE__ == $0
  port = ARGV.first.to_i.to_s == ARGV.first.to_s ? ARGV.first.to_i : nil
  Meet4Xmas::Server::run port
  puts "Server living at port #{port} - api version: #{Meet4Xmas::Server::API::VERSION}"
end
