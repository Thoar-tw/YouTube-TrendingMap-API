# frozen_string_literal: true

CONTINENT_COUNTRY_CODES = JSON.parse(
  File.read('config/continent_country_codes.json')
)

module YouTubeTrendingMap
  module Mapper
    # Data structure of trending list queried from Youtube
    class ContinentTopVideosList
      include Mixins::TopVideosAggregator

      def initialize(api_key, gateway_class = YouTubeTrendingMap::YoutubeAPI)
        @api_key = api_key
        @gateway_class = gateway_class
      end

      def get(continent, category_id, max_results)
        videos_lists =
          get_lists_from_countries_in_(continent, category_id, max_results)

        build_entity(aggregate(videos_lists), continent)
      end

      def build_entity(data, continent)
        Entity::ContinentTopVideosList.new(
          id: nil,
          type: 'continent',
          count: data.length,
          belonging_continent: continent,
          videos: data
        )
      end

      private

      # rubocop:disable Metrics/MethodLength
      def get_lists_from_countries_in_(continent, category_id, max_results)
        country_codes =
          case continent
          when 'asia'
            %w[tw jp kr sg in]
          when 'europe'
            %w[fr de se es]
          when 'north america'
            %w[us ca mx]
          when 'south america'
            %w[py ar br]
          when 'africa'
            %w[za eg ng]
          end

        # country_codes = country_codes_in_(continent)
        country_codes.map do |country_code|
          Mapper::CountryTopVideosList
            .new(@api_key, @gateway_class)
            .get(country_code, category_id, max_results)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def country_codes_in_(continent)
        CONTINENT_COUNTRY_CODES[continent].map do |country_code, _|
          country_code
        end
      end
    end
  end
end
