require 'rubygems'
require 'dm-core'
require File.join File.dirname(__FILE__), '..', 'geo'

module Meet4Xmas
module Persistence
  class Location
    include DataMapper::Resource

    property :id, Serial, :key => true

    property :latitude, Float, :required => true
    property :longitude, Float, :required => true
    property :title, String
    property :description, String

    validates_within :latitude, :set => -90..90
    validates_within :longitude, :set => -180..180

    def self.HPI
        self.new :title => "Hasso-Plattner-Institue",
                 :description => "Here is the shit!!1!",
                 :latitude => 52.393957,
                 :longitude => 13.132473
    end

    def self.from_address(*address)
        result = Geo.geocode *address
        return nil unless result and result.size > 0
        self.new :title => address.first || '',
                 :description => result[0]['formatted_address'] || '',
                 :latitude =>result[0]['geometry']['location']['lat'] || 0,
                 :longitude => result[0]['geometry']['location']['lng'] || 0
    end

    def self.from_type(type)
        require 'csv'
        case type
        when LocationType::ChristmasMarket then
            csv_filename = File.join(File.dirname(__FILE__),'..','..','OpenData','weihnachtsmaerkte_geo.csv')
            @ChristmasMarketLocations ||= CSV.open(csv_filename, 'r', :headers=>true).map do | row |
                self.new :title => row['Name'],
                         :description => "#{row['Street']}, #{row['City']}",
                         :latitude =>row['Latitude'].to_f,
                         :longitude => row['Longitude'].to_f
            end
        else
            []
        end
    end

    def to_hash
      { 'longitude' => longitude, 'latitude' => latitude, 'title' => title, 'description' => description }
    end
  end
end
end
