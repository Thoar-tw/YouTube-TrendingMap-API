# frozen_string_literal: true

require_relative 'hot_videos_lists'
require_relative 'hot_videos'

module YouTubeTrendingMap
  module HotVideosRepository
    # Finds the right repository for an entity object or class
    class For
      ENTITY_REPOSITORY = {
        Entity::HotVideosList => HotVideosLists,
        Entity::HotVideo => HotVideos
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
