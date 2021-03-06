# frozen_string_literal: true

module YouTubeTrendingMap
  module Services
    # Transaction to get hot videos list from YouTube API
    class GetCountryTopVideosList
      include Dry::Transaction

      step :get_from_api

      private

      def get_from_api(input)
        country_top_videos_list =
          YouTubeTrendingMap::Mapper::CountryTopVideosList
          .new(Api.config.GOOGLE_CLOUD_KEY)
          .get(input[:region_code], input[:category_id], 10)

        Success(Value::Result.new(status: :ok, message: country_top_videos_list))
      rescue StandardError => error
        Failure(Value::Result.new(status: :not_found, message: error.to_s))
      end
    end
  end
end
