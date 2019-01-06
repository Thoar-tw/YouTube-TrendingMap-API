# frozen_string_literal: true

module YouTubeTrendingMap
  module Services
    # Transaction to get hot videos list from YouTube API
    class GetContinentTopVideosList
      include Dry::Transaction

      step :get_from_api

      private

      def get_from_api(input)
        continent_top_videos_list =
          YouTubeTrendingMap::Mapper::ContinentTopVideosList
          .new(Api.config.GOOGLE_CLOUD_KEY)
          .get(input[:continent_name], input[:category_id], 10)

        Success(Value::Result.new(status: :ok, message: continent_top_videos_list))
      rescue StandardError => error
        Failure(Value::Result.new(status: :not_found, message: error.to_s))
      end
    end
  end
end
