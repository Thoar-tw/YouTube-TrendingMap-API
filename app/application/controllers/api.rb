# frozen_string_literal: true

require 'roda'

module YouTubeTrendingMap
  # Web app
  class Api < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt
    plugin :all_verbs
    plugin :caching

    DEFAULT_CATEGORY = 0
    DEFAULT_MAX_RESULTS = 10

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message =
          "YouTubeTrendingMap API v1 at /api/v1/ in #{Api.environment} mode"

        result_response = Representer::HttpResponse.new(
          Value::Result.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do # rubocop:disable Metrics/BlockLength
        routing.on 'hot_videos' do
          routing.on String, String do |region_code, category_id|
            # POST /hot_videos/{region_code}/{category_id}
            routing.post do
              result = Services::GetHotVideosList.new.call(
                region_code: region_code, category_id: category_id
              )

              if result.failure?
                failure = Representer::HttpResponse.new(result.failure)
                routing.halt failure.http_status_code, failure.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::HotVideosList.new(result.value!.message).to_json
            end
          end
        end

        routing.on 'top_videos' do # rubocop:disable Metrics/BlockLength
          routing.on 'global' do
            routing.on String do |category_id|
              # POST /top_videos/global/{category_id}
              routing.post do
                response.cache_control public: true, max_age: 600

                result = Services::GetGlobalTopVideosList.new.call(
                  category_id: category_id
                )
                if result.failure?
                  failure = Representer::HttpResponse.new(result.failure)
                  routing.halt failure.http_status_code, failure.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::GlobalTopVideosList.new(result.value!.message).to_json
              end
            end
          end

          routing.on 'continent' do
            routing.on String, String do |continent_name, category_id|
              # POST /top_videos/continent/{continent_name}/{category_id}
              routing.post do
                continent_name = continent_name.gsub('%20', ' ')
                result = Services::GetContinentTopVideosList.new.call(
                  continent_name: continent_name, category_id: category_id
                )
                if result.failure?
                  failure = Representer::HttpResponse.new(result.failure)
                  routing.halt failure.http_status_code, failure.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::ContinentTopVideosList.new(result.value!.message).to_json
              end
            end
          end

          routing.on 'country' do
            routing.on String, String do |region_code, category_id|
              # POST /top_videos/country/{region_code}/{category_id}
              routing.post do
                result = Services::GetCountryTopVideosList.new.call(
                  region_code: region_code, category_id: category_id
                )

                if result.failure?
                  failure = Representer::HttpResponse.new(result.failure)
                  routing.halt failure.http_status_code, failure.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::CountryTopVideosList
                  .new(result.value!.message)
                  .to_json
              end
            end
          end
        end

        routing.on 'favorite_videos' do # rubocop:disable Metrics/BlockLength
          routing.is do # rubocop:disable Metrics/BlockLength
            # GET /favorite_videos
            routing.get do
              result = Services::ListFavoriteVideos.new.call

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::FavoriteVideosList.new(
                result.value!.message
              ).to_json
            end

            # POST /favorite_videos?videos=
            routing.post do
              # Add video to favorite list
              result = Services::AddFavoriteVideo.new.call(
                videos_request: Value::VideosRequest.new(routing.params)
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              http_response.to_json
            end

            # DELETE /favorite_videos?videos=
            routing.delete do
              # Delete video from favorite list
              result = Services::DeleteFavoriteVideo.new.call(
                videos_request: Value::VideosRequest.new(routing.params)
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              http_response.to_json
            end
          end

          routing.on 'all' do
            # POST /favorite_videos/all?videos=
            routing.post do
              # Add videos to favorite list
              result = Services::AddFavoriteVideosByList.new.call(
                videos_request: Value::VideosRequest.new(routing.params)
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              http_response.to_json
            end
          end
        end
      end
    end
  end
end
