# frozen_string_literal: true

module YouTubeTrendingMap
  module Services
    # Transaction to store favorite videos to database
    class AddFavoriteVideo
      include Dry::Transaction

      step :validate_input
      step :store_video

      private

      NIL_MSG = 'Some inputs are nil!'
      DB_ERR_MSG = 'Having trouble accessing the database'

      def validate_input(input)
        videos_request = input[:videos_request].call
        if videos_request.success?
          Success(input.merge(videos: videos_request.value!))
        else
          Failure(Value::Result.new(status: :bad_request, message: NIL_MSG))
        end
      end

      def store_video(input)
        video = build_entity(input[:videos])
        FavoriteVideosRepository::For
          .entity(video).find_or_create(video)
          .yield_self do |result|
            Success(Value::Result.new(status: :created, message: result))
          end
      rescue StandardError => error
        puts error
        puts error.backtrace.join("\n")
        Failure(Value::Result.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def build_entity(input)
        Entity::FavoriteVideo.new(
          origin_id: input['origin_id'],
          title: input['title'],
          channel_title: input['channel_title'],
          view_count: input['view_count'].to_i,
          embed_link: input['embed_link']
        )
      end
    end
  end
end
