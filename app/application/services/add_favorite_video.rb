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
        if !input_is_nil(input)
          input[:video_entity] = build_entity(input)
          Success(input)
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
        if (video = input[:video_entity])
          FavoriteVideosRepository::For.entity(video).find_or_create(video)
          Success(
            Value::Result.new(
              status: :created,
              message: 'Success add the video to favorite'
            )
          )
        end
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure(
          Value::Result.new(
            status: :internal_error,
            message: 'Having trouble accessing the database'
          )
        )
      end

      def input_is_nil(input)
        input[:origin_id].nil? || input[:title].nil? ||
          input[:channel_title].nil? || input[:view_count].nil? ||
          input[:embed_link].nil?
      end

      def build_entity(input)
        Entity::FavoriteVideo.new(
          origin_id: input[:origin_id],
          title: input[:title],
          channel_title: input[:channel_title],
          view_count: input[:view_count],
          embed_link: input[:embed_link]
        )
      end
    end
  end
end
