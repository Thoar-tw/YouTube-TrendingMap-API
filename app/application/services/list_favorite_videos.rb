# frozen_string_literal: true

require 'dry/transaction'

module YouTubeTrendingMap
  module Services
    # Retrieves array of all listed project entities
    class ListFavoriteVideos
      include Dry::Transaction

      step :retrieve_videos

      private

      def retrieve_videos # rubocop:disable Metrics/MethodLength
        FavoriteVideosRepository::For
          .klass(Entity::FavoriteVideo).all
          .yield_self { |videos| Value::FavoriteVideosList.new(videos) }
          .yield_self do |list|
            Success(Value::Result.new(status: :ok, message: list))
          end
      rescue StandardError
        Failure(
          Value::Result.new(
            status: :internal_error,
            message: 'Cannot access database'
          )
        )
      end
    end
  end
end
