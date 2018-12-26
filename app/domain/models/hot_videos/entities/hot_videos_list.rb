# frozen_string_literal: true

# exactly trending videos from youtube api query
require_relative 'hot_video.rb'

module YouTubeTrendingMap
  module Entity
    # Domain entity for Youtube hot videos lists
    class HotVideosList < Dry::Struct
      include Dry::Types.module

      attribute :id,                  Integer.optional
      attribute :count,               Strict::Integer
      attribute :belonging_country,   Strict::String
      attribute :videos,              Strict::Array.of(HotVideo)

      def to_attr_hash
        to_hash.reject { |key, _| %i[id videos].include? key }
      end
    end
  end
end
