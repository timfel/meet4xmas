# ruby test script using the hessian client
# You get the best effect if you require this file in irb.

# load some general server API information
require File.expand_path('../lib/server/api', __FILE__)
puts "Meet4Xmas API version #{Meet4Xmas::Server::API::VERSION}"

# create the hessian client instance
require File.expand_path('../lib/hessian_client/lib/hessian', __FILE__)
@address = "http://localhost:4567/#{Meet4Xmas::Server::API::VERSION}/"
puts "Connecting to RPC server at '#{@address}'"
@hessian_client = Hessian::HessianClient.new(@address)

# hook up method_missing with a RPC call
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
  if Meet4Xmas::Server::API::ALL_MESSAGES.include? meth.to_s
    do_rpc(meth, *args, &block)
  else
    super
  end
end

# print a help hint
puts "For help enter 'h'"
def h
  puts 'available methods:'
  Meet4Xmas::Server::API::ALL_MESSAGES.each { |m| puts "  #{m}" }
  nil
end
