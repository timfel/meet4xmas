require 'net/http'

module Meet4Xmas
  module WebAPI
    class GoogleDistanceMatrix
      QUERY_CHUNK_SIZE = 50

      def initialize( origins, destinations, options = {} )
        @origins = origins; raise "origins is missing" unless @origins
        @destinations = destinations; raise "destinations is missing" unless @destinations
        
        valid_modes = %w{ driving walking bicycling }
        @mode = options[:mode] ? options[:mode] : 'driving'
        raise "mode '#{@mode}' not in #{valid_modes}!" unless valid_modes.include? @mode
        
        @sensor = !!options[:sensor]

        raise 'this implementation can currently handle at most 50 origins' if @origins.count > 50

        @base_url = "http://maps.googleapis.com/maps/api/distancematrix/json"
      end

      def url(destinations)
        uri_origins = URI.escape(@origins.map{|l|"#{l.latitude},#{l.longitude}"}.join('|'))
        uri_destinations = URI.escape(destinations.map{|l|"#{l.latitude},#{l.longitude}"}.join('|'))
        "#{@base_url}?sensor=#{@sensor ? 'true' : 'false'}" +
          "&origins=#{uri_origins}&destinations=#{uri_destinations}" +
          "&mode=#{@mode}"
      end

      def query_rows
        query_destinations = @destinations.clone

        # we split up the destinations in chunks of QUERY_CHUNK_SIZE and perform one request per chunk
        results = nil
        while query_destinations.count > 0
          resp = nil
          begin
            # get results for a subset of destinations
            resp = Net::HTTP.get_response( URI.parse url(query_destinations.shift(QUERY_CHUNK_SIZE)) )
          rescue
            puts 'error while fetching google data'
            return []
          end

          result = nil
          case resp
          when Net::HTTPSuccess
            result = JSON.parse(resp.body)
          else
            puts "Unexpected response #{resp}"
            return []
          end

          # TODO: check result status (and element status)
          if result and result['rows'] and result['rows'].first and result['rows'].first['elements']
            # append to existing results for all destinations
            unless results
              results = result['rows']
            else
              result['rows'].each_with_index do |row,index|
                results[index]['elements'] += row['elements']
              end
            end
          else
            puts result.to_yaml
            return []
          end
        end

        results
      end

      def closest_to_all
        # for all destinations, sum up the distances from the origins
        distance_sums = [0] * @destinations.count
        query_rows.each do |row| # row is an origin
          row['elements'].each_with_index do |element, index| # element is a destination
            distance_sums[index] += element['duration']['value']
          end
        end
        
        # find destination index with smallest distance to all origins
        # this will be the index of the distance_sums entry with the lowest value
        min_distance = Float::INFINITY
        min_index = nil
        distance_sums.each_with_index do |distance, index|
          if distance < min_distance
            min_index = index
            min_distance = distance
          end
        end
        min_index ? @destinations[min_index] : nil
      end

      attr_accessor :origins, :destinations, :mode

      def sensor?;  @sensor; end
      def sensor=(sensor);  @sensor = !!sensor; end
      def sensor!;  @sensor = true; end
    end
  end
end
