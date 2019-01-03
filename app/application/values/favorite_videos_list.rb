# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module YouTubeTrendingMap
  module Value
    # List of videos
    FavoriteVideosList = Struct.new(:videos)
  end
end
