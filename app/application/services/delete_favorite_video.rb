# frozen_string_literal: true

module YouTubeTrendingMap
  module Services
    # Transaction to store favorite videos to database
    class DeleteFavoriteVideo
      include Dry::Transaction

      step :delete_video

      private

      def delete_video(input) # rubocop:disable Metrics/MethodLength
        FavoriteVideosRepository::FavoriteVideos
          .delete_video(input[:origin_id])

        Success(
          Value::Result.new(
            status: :ok,
            message: 'Success delete the video from favorite'
          )
        )
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure(
          Value::Result.new(
            status: :internal_error,
            message: 'Having trouble accessing the database'
          )
        )
      end
    end
  end
end
