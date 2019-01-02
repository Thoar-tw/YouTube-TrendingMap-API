# frozen_string_literal: true

require 'roda'

module YouTubeTrendingMap
  # Web app
  class Api < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt
    plugin :all_verbs

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
                # downcase the input for continent name
                continent_name = continent_name.downcase

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
          routing.is do
            # GET /favorite_videos
            routing.get do
              result = Services::ListFavoriteVideos.new.call(
                list_request: Value::ListRequest.new(routing.params)
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::FavoriteVideo.new(
                result.value!.message
              ).to_json
            end
          end
          routing.on 'add' do
            # POST /favorite_videos/add
            routing.post do
              result = Services::AddFavoriteVideo.new.call(
                origin_id: routing.params['origin_id'],
                title: routing.params['title'],
                channel_title: routing.params['channel_title'],
                view_count: routing.params['view_count'].to_i,
                embed_link: routing.params['embed_link']
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

          routing.on 'delete' do
            # POST /favorite_videos/delete
            routing.post do
              result = Services::DeleteFavoriteVideo.new.call(
                origin_id: routing.params['origin_id']
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
