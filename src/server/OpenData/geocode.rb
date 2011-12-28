require 'rubygems'
require 'json'
require 'net/http'
require 'csv'

def geocode(*address)
	address = address.map{|a|URI.escape(a)}.join(',')
	base_url = "http://maps.googleapis.com/maps/api/geocode/json"
	url = "#{base_url}?sensor=false&address=#{address}"
	uri = URI.parse(url)

	resp = Net::HTTP.get_response(uri)
	case resp
	when Net::HTTPSuccess
		data = resp.body
		result = JSON.parse(data)
		return result
	else
		puts "Unexpected response #{resp}"
		return nil
	end
end

def get_coords(*address)
	result = geocode(*address)
	if result == nil
		return nil
	else
		results = result['results']
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

def geocode_file(input_file, output_file)
	CSV.open(output_file, 'wb') do |output_csv|
		CSV.foreach(input_file, :headers => true, :return_headers => true) do |row|
			if row.header_row?
				row['Latitude'] = 'Latitude'
				row['Longitude'] = 'Longitude'
				output_csv << row
			else
				coords = get_coords(row['Street'], row['City'])
				if coords != nil
					row['Latitude'] = coords['lat']
					row['Longitude'] = coords['lng']
				else
					puts "no coords for #{row.inspect}"
					row['Latitude'] = ''
					row['Longitude'] = ''
				end
				output_csv << row
			end
			sleep 1
		end
	end
end

if __FILE__ == $0
	if ARGV.length == 2
		geocode_file(*ARGV)
	else
		puts "Usage: #{$0} input_file output_file"
	end
end
