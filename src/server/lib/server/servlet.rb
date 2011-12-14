# require the hessian servlet base class and the service interface
require File.expand_path('../../java/init', __FILE__)
require 'lib/java/hessian'
module Java
  module Hessian
    include_class 'com.caucho.hessian.server.HessianServlet'
  end
  module Wire
    java_import 'org.meet4xmas.wire.IServiceAPI'
  end
end

# require some general Server API info
require File.expand_path('../api', __FILE__)
# and the servlet handler
require File.expand_path('../handler', __FILE__)

# the Java Servlet. The ServletHandler (see handler.rb) performs the actual work.
module Meet4Xmas
module Server
  class Servlet < Java::Hessian::HessianServlet
    include Java::Wire::IServiceAPI

    def initialize(*args, &block)
      super
      @handler = ServletHandler.new
    end
    
    Server::API::ALL_MESSAGES.each do |meth|
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
end
end
