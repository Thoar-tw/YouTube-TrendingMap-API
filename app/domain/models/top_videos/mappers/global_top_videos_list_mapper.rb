# frozen_string_literal: true

require 'concurrent'

module YouTubeTrendingMap
  module Mapper
    # Data structure of trending list queried from Youtube
    class GlobalTopVideosList
      include Mixins::TopVideosAggregator

      def initialize(api_key, gateway_class = YouTubeTrendingMap::YoutubeAPI)
        @api_key = api_key
        @gateway_class = gateway_class
      end

      def get(category_id, max_results)
        videos_lists = get_lists_from_continents(category_id, max_results)
        # videos_lists = get_lists_from_continents_concurrently(category_id, max_results)
        build_entity(aggregate(videos_lists))
      end

      def build_entity(data)
        YouTubeTrendingMap::Entity::GlobalTopVideosList.new(
          id: nil,
          type: 'global',
          count: data.length,
          videos: data
        )
      end

      private

      def get_lists_from_continents(category_id, max_results)
        continents = ['asia', 'north america', 'europe']
        # continents = CONTINENT_COUNTRY_CODES.keys
        list = []
        continents.each do |continent|
          list << Mapper::ContinentTopVideosList
                  .new(@api_key, @gateway_class)
                  .get(continent, category_id, max_results)
        end

        list
      end

      # rubocop:disable Metrics/MethodLength
      def get_lists_from_continents_concurrently(category_id, max_results)
        continents = ['asia', 'north america', 'europe']
        # continents = CONTINENT_COUNTRY_CODES.keys
        promises =
          continents.map do |continent|
            Concurrent::Promise
              .execute do
                Mapper::ContinentTopVideosList
                  .new(@api_key, @gateway_class)
                  .get(continent, category_id, max_results)
              end
              .rescue { |error| puts error.inspect }
          end
        promises.map { |promise| promise&.value }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
