require 'net/http'
require 'rubygems'
require 'nokogiri'

module Meet4Xmas
  module WebAPI
    class VBBDirections
      def initialize(options = {})
        @host = "demo.hafas.de"
        @url_path = "/bin/pub/vbb-fahrinfo/relaunch2011/extxml.exe/"
        @origin = options[:origin]
        @destination = options[:destination]
      end

      def journey_attribute(jouney_node, attribute_name)
        jouney_node.xpath('./JourneyAttributeList').children.find do |c|
          if c.name == 'JourneyAttribute'
            a = c.xpath('./Attribute').attr('type')
            a.value  == attribute_name if a
          end
        end
      end

      def path
        begin
          time = Time.now
          path = []
          request_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                          <ReqC accessId=\"VBB-HPIFPJ2011\" ver=\"1.1\" prod=\"Meet4Xmas\" lang=\"EN\">
                          <ConReq>
                              <Start>
                                  <Address y=\"#{(@origin.latitude*1000000).to_i}\" x=\"#{(@origin.longitude*1000000).to_i}\" />
                                  <Prod prod=\"1111111111111111\"/>
                              </Start>
                              <Dest>
                                  <Address y=\"#{(@destination.latitude*1000000).to_i}\" x=\"#{(@destination.longitude*1000000).to_i}\" />
                              </Dest>
                              <ReqT time=\"#{ time.hour }:#{ time.min < 10 ? '0' : ''}#{ time.min }\" date=\"#{ time.year }#{ time.month < 10 ? '0' : ''}#{ time.month }#{ time.day < 10 ? '0' : ''}#{ time.day }\" a=\"0\"/>
                              <RFlags b=\"1\" f=\"1\" nrChanges=\"4\" sMode=\"N\" />
                          </ConReq>
                          </ReqC>"

          http = Net::HTTP.new(@host)
          response = http.post(@url_path, request_body)
          case response
          when Net::HTTPSuccess
            response = Nokogiri::XML(response.body)
            con_res = response.xpath('/ResC/ConRes').first
            raise 'Missing ConRes' unless con_res
            puts "Warning: unknown ConRes dir '#{con_res['dir']}'" unless con_res['dir'] == 'O'
            connection_list = con_res.xpath('./ConnectionList').first
            raise 'Missing ConnectionList' unless connection_list
            fastest_connection = connection_list.xpath('Connection').min do |connection1, connection2|
              duration1 = connection1.xpath('./Overview/Duration').text.strip
              duration2 = connection2.xpath('./Overview/Duration').text.strip
              duration1 <=> duration2
            end

            fastest_connection.xpath('./ConSectionList/ConSection').each do | conSection |
              stop = conSection.xpath('./Departure/BasicStop')
              travel_info = if conSection.children.map {|c| c.name}.include? "GisRoute"
                conSection.xpath('./GisRoute').attr('type').value == 'FOOT' ? "Walk some time - #{conSection.xpath('./GisRoute/Duration/Time').text.strip}" : ""
              else
                name_attribute = journey_attribute conSection.xpath('./Journey'), 'NAME'
                direction_attribute = journey_attribute conSection.xpath('./Journey'), 'DIRECTION'
                stop_count = conSection.xpath('./Journey/PassList').children.size - 1
                "Go with #{name_attribute.xpath('./Attribute/AttributeVariant/Text').text.strip} (#{direction_attribute.xpath('./Attribute/AttributeVariant/Text').text.strip}) for #{stop_count} stop#{'s' if stop_count > 1}"
              end
              if stop.children.map {|c| c.name}.include? 'Address'
                path << (Persistence::Location.new :title => "#{stop.xpath('./Address').attr('name').value}",
                         :description => "#{travel_info}",
                         :longitude => stop.xpath('./Address').attr('x').value.to_i / 1000000,
                         :latitude => stop.xpath('./Address').attr('y').value.to_i / 1000000)
              else
                path << (Persistence::Location.new :title => "Station #{stop.xpath('./Station').attr('name').value}",
                         :description => "#{travel_info}",
                         :longitude => stop.xpath('./Station').attr('x').value.to_i / 1000000,
                         :latitude => stop.xpath('./Station').attr('y').value.to_i / 1000000)
              end
            end
          else
            raise "unexpected response: #{response}"
          end
          return path << @destination
        rescue Exception => e
          puts "Error in VBBDirections.path: #{e}"
          puts e.backtrace
          return [@origin, @destination]
        end
      end

      def origin; @origin; end
      def origin=(origin); @origin = origin; end

      def destination; @destination; end
      def destination=(destination); @destination = destination; end
    end
  end
end