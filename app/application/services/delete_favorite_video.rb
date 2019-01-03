# frozen_string_literal: true

module YouTubeTrendingMap
  module Services
    # Transaction to store favorite videos to database
    class DeleteFavoriteVideo
      include Dry::Transaction

      step :validate_input
      step :delete_video

      private

      def validate_input(input) # rubocop:disable Metrics/MethodLength
        video_request = input[:video_request].call
        if video_request.success?
          Success(input.merge(video: video_request.value!))
        else
          Failure(
            Value::Result.new(
              status: :bad_request,
              message: 'Some inputs are nil!'
            )
          )
        end
      end

      def delete_video(input) # rubocop:disable Metrics/MethodLength
        video = input[:video]
        FavoriteVideosRepository::FavoriteVideos
          .delete_video(video['origin_id'])

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
