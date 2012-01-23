require 'json'
require 'net/http'

module Meet4Xmas
module WebAPI
  module GoogleGeocoding
    def self.geocode(*address)
      address = address.map{|a|URI.escape(a)}.join(',')
      base_url = "http://maps.googleapis.com/maps/api/geocode/json"
      url = "#{base_url}?sensor=false&address=#{address}"
      uri = URI.parse(url)

      resp = Net::HTTP.get_response(uri)
      case resp
      when Net::HTTPSuccess
        data = resp.body
        result = JSON.parse(data)
        return result['results']
      else
        puts "Unexpected response #{resp}"
        return nil
      end
    end

    def self.get_coords(*address)
      result = geocode(*address)
      if result == nil
        return nil
      else
        if results.length >= 1
          if results.length > 1
            puts "multiple results for #{address.inspect}"
          end
          return results[0]['geometry']['location']
        else
          return nil
        end
      end
    end
  end
end
end
