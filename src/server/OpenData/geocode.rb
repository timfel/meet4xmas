require 'rubygems'
require 'csv'
require File.join File.dirname(__FILE__), '..', 'lib', 'webapi', 'google_geocoding'

def geocode_file(input_file, output_file)
	CSV.open(output_file, 'wb') do |output_csv|
		CSV.foreach(input_file, :headers => true, :return_headers => true) do |row|
			if row.header_row?
				row['Latitude'] = 'Latitude'
				row['Longitude'] = 'Longitude'
				output_csv << row
			else
				coords = Meet4Xmas::WebAPI::GoogleGeocoding.get_coords(row['Street'], row['City'])
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
