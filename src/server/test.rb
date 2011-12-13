# ruby test script using the hessian client
# You get the best effect if you require this file in irb.

require 'rubygems'
require 'hessian'

@address = 'http://localhost:4567/1/'
puts "Connecting to RPC server at '#{@address}'"
@hessian_client = Hessian::HessianClient.new(@address)

@rpc_methods = %w(registerAccount deleteAccount
  createAppointment getAppointment getTravelPlan
  joinAppointment declineAppointment finalizeAppointment)

def do_rpc(meth, *args, &block)
  response = @hessian_client.send(meth, *args, &block)
  if response != nil
    if response.kind_of?(Hash)
      if response['success']
        response['payload']
      else
        puts "error #{response['error']['code']}: #{response['error']['message']}"
      end
    else
      puts "error: unexpected response type '#{response.inspect}' (#{response.class})"
    end
  else
    puts "error: no response"
  end
rescue => e
  puts "error performing RPC '#{meth}':"
  puts "  #{e}"
  trace = e.backtrace.join("\n    ")
  puts "    #{trace}"
end

def method_missing(meth, *args, &block)
  if @rpc_methods.include? meth.to_s
    do_rpc(meth, *args, &block)
  else
    super
  end
end

puts "For help enter 'h'"
def h
  puts 'available methods:'
  @rpc_methods.each { |m| puts "  #{m}" }
  nil
end
