# frozen_string_literal: true

module YouTubeTrendingMap
  module Services
    # Transaction to store favorite videos to database
    class AddFavoriteVideosByList
      include Dry::Transaction

      step :validate_input
      step :request_worker

      private

      PROCESSING_MSG = 'Processing the addition request'
      ADD_ERR = 'Could not add these videos to database'

      def validate_input(input) # rubocop:disable Metrics/MethodLength
        videos_request = input[:videos_request].call
        if videos_request.success?
          Success(input.merge(videos: videos_request.value!))
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
        input[:videos].each do |video|
          puts video
          break
        end

        # input[:videos]
        #   .yield_self { |videos| Value::FavoriteVideosList.new(videos) }
        #   .yield_self do |list|
        #     puts list.videos.length
        #   end


        Success(
          Value::Result.new(
            status: :created,
            message: 'Success add the video(s) to favorite'
          )
        )
      rescue StandardError => error
        puts error
        puts error.backtrace.join("\n")
        Failure(
          Value::Result.new(
            status: :internal_error,
            message: 'Having trouble accessing the database'
          )
        )
      end

      def request_worker(input) # rubocop:disable Metrics/MethodLength
        puts 'in request_worker'
        # puts input[:videos]

        input[:videos]
          .map { |video| build_entity(video) }
          .yield_self { |videos| Value::FavoriteVideosList.new(videos)}
          .yield_self do |list|
            # puts list
            Messaging::Queue
              .new(Api.config.ADDITION_QUEUE_URL, Api.config)
              .send(Representer::FavoriteVideosList.new(list).to_json)
          end

        puts 'after sending message queue...'

        Failure(Value::Result.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError => error
        puts [error.inspect, error.backtrace].flatten.join("\n")
        Failure(Value::Result.new(status: :internal_error, message: ADD_ERR))
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
