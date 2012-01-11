require 'net/http'

module Meet4Xmas
  module WebAPI
    class GoogleDirections
      def initialize( options = {} )
        valid_modes = %w{ driving walking bicycling }
        @mode = options[:mode] ? options[:mode] : 'driving'
        raise "mode '#{@mode}' not in #{valid_modes}!" if not valid_modes.include? @mode
        @origin = options[:origin] ? options[:origin] : { :latitude => 0, :longitude => 0 }
        @destination = options[:destination] ? options[:destination] : { :latitude => 0, :longitude => 0 }
        @sensor = !!options[:sensor]
        @base_url = "http://maps.google.com/maps/api/directions/json"
      end

      def url
        "#{@base_url}?sensor=#{@sensor ? 'true' : 'false'}" +
          "&origin=#{URI.escape "#{@origin.latitude},#{@origin.longitude}"}" +
          "&destination=#{URI.escape "#{@destination.latitude},#{@destination.longitude}"}" +
          "&mode=#{@mode}"
      end

      def path
        resp = Net::HTTP.get_response( URI.parse url )
        result = nil
        case resp
        when Net::HTTPSuccess
          data = resp.body
          result = JSON.parse(data)
        else
          puts "Unexpected response #{resp}"
          return []
        end
        if result and result['routes'] and result['routes'].first and result['routes'].first['legs']
          step_number = 0
          result['routes'].first['legs'].first['steps'].map do |step|
            Persistence::Location.new :title => "Step ##{step_number += 1}",
                         :description => step['html_instructions'],
                         :longitude => step['start_location']['lng'],
                         :latitude =>step['start_location']['lat']
          end
        else
          [ origin ]
        end << location
      end

      def mode; @mode; end
      def mode=(mode); @mode = mode; end

      def origin; @origin; end
      def origin=(origin); @origin = origin; end

      def destination; @destination; end
      def destination=(destination); @destination = destination; end

      def sensor?;  @sensor; end
      def sensor=(sensor);  @sensor = !!sensor; end
      def sensor!;  @sensor = true; end
    end
  end
end
