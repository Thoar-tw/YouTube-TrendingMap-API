# frozen_string_literal: true

require 'yaml'

module YouTubeTrendingMap
  module Mapper
    COUNTRY_CODES = YAML.safe_load(File.read('config/country_code_iso_alpha2.yml'))

    # Provide access to country data from OSM
    class Country
      def initialize(gateway_class = OSMDataAPI)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def query(country_name)
        data = @gateway.country_data(country_name)
        build_entity(data)
      end

      def build_entity_from_region_code(region_code)
        country_name = COUNTRY_CODES.key(region_code.upcase)
        data = @gateway.country_data(country_name)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from raw response data structure
      class DataMapper
        def initialize(country_data)
          @country_data = country_data
        end

        def build_entity
          Entity::Country.new(
            id: nil,
            place_id: place_id,
            name: name,
            latitude: latitude,
            longitude: longitude
          )
        end

        private

        def place_id
          @country_data['place_id'].to_i
        end

        def name
          @country_data['display_name']
        end

        def latitude
          @country_data['lat'].to_f
        end

        def longitude
          @country_data['lon'].to_f
        end
      end
    end
  end
end
