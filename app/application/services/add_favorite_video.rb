# frozen_string_literal: true

module YouTubeTrendingMap
  module Services
    # Transaction to store favorite videos to database
    class AddFavoriteVideo
      include Dry::Transaction

      step :validate_input
      step :store_video

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

      def store_video(input) # rubocop:disable Metrics/MethodLength
        video = build_entity(input[:video])
        FavoriteVideosRepository::For.entity(video).find_or_create(video)
        Success(
          Value::Result.new(
            status: :created,
            message: 'Success add the video to favorite'
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

      def build_entity(input)
        Entity::FavoriteVideo.new(
          origin_id: input['origin_id'],
          title: input['title'],
          channel_title: input['channel_title'],
          view_count: input['view_count'],
          embed_link: input['embed_link']
        )
      end
    end
  end
end
