# frozen_string_literal: false

require 'roda'
require 'slim'
require 'slim/include'

module YouTubeTrendingMap
  # Web app
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt

    DEFAULT_CATEGORY = 0
    DEFAULT_MAX_RESULTS = 10

    hot_videos_list = nil

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "YouTubeTrendingMap API v1 at /api/v1/ in #{Api.environment} mode"

        result_response = Representer::HttpResponse.new(
          Value::Result.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do # rubocop:disable Metrics/BlockLength
        routing.on 'hot_videos' do
          routing.on String, String do |country_name, category_id|
            # POST /hot_videos/{country_name}/{category_id}
            routing.post do
              # If user request from country name field, mapping it to region code
              region_code = COUNTRY_CODES[country_name]
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

          routing.on 'continent' do # rubocop:disable Metrics/BlockLength
            routing.on String, String do |continent_name, category_id|
              routing.post do
                ### user enter specific region and category
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

          routing.on 'country' do # rubocop:disable Metrics/BlockLength
            routing.post do # rubocop:disable Metrics/BlockLength
              ### user enter specific region and category
              # If user request from country name field, mapping it to region code
              unless routing.params['country_name'].nil?
                region_code = COUNTRY_CODES[routing.params['country_name']]
                routing.params['region_code'] = region_code
              end

              # Check if region code request matches it's valid regex
              region_code_request = Forms::RegionCodeRequest.call(routing.params)
              if region_code_request.failure?
                error = region_code_request.errors[:region_code][0]
                puts 'region_code_request: ' + error
              end

              # Check if category id request matches it's valid regex
              category_id_request = Forms::CategoryIdRequest.call(routing.params)
              if category_id_request.failure?
                error = category_id_request.errors[:category_id][0]
                puts 'category_id_request: ' + error
              end

              request[:region_code] = region_code_request[:region_code]
              request[:category_id] = category_id_request[:category_id]
              country_top_videos_list_result =
                Services::GetCountryTopVideosList.new.call(request)

              if country_top_videos_list_result.failure?
                failure = country_top_videos_list_result.failure
                puts 'country_top_videos_list_result: ' + failure
              end

              puts  'Getting top videos list for ' + request[:region_code] +
                    ' in category ' + request[:category_id]
              country_top_videos_list = country_top_videos_list_result.value!
            end
          end
        end
      end
    end
  end
end
