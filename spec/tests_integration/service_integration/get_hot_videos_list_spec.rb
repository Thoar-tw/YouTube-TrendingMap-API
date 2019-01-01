# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'

describe 'YouTube Trending Videos Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_youtube(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Get hot videos' do
    it 'HAPPY: should return a list of YouTube hot videos from a country' do
      # GIVEN: a valid region code parameter & category id request for hot videos:
      list =  YouTubeTrendingMap::Mapper::HotVideosList
              .new(GOOGLE_CLOUD_KEY)
              .get(REGION_CODE, DEFAULT_CATEGORY, DEFAULT_MAX_RESULTS)

      # WHEN: the service is called with the request form object
      list_made = YouTubeTrendingMap::Services::GetHotVideosList.new.call(
        region_code: REGION_CODE, category_id: DEFAULT_CATEGORY
      )

      # THEN: the result should report success..
      _(list_made.success?).must_equal true
      # and provide a video list entity with the right details
      rebuilt = list_made.value!.message
      _(rebuilt.count).must_equal(list.count)

      list.videos.each do |video|
        found = rebuilt.videos.find do |potential|
          potential.origin_id == video.origin_id
        end

        _(found.publish_time).must_equal(video.publish_time)
        _(found.title).must_equal(video.title)
        _(found.description).must_equal(video.description)
        _(found.channel_title).must_equal(video.channel_title)
        _(found.view_count).must_equal(video.view_count)
        _(found.like_count).must_equal(video.like_count)
        _(found.dislike_count).must_equal(video.dislike_count)
        _(found.embed_link).must_equal(video.embed_link)
      end
    end

    it 'SAD: should gracefully fail for invalid region code' do
      # WHEN: the service is called with invalid region code
      list_made = YouTubeTrendingMap::Services::GetHotVideosList.new.call(
        region_code: 'ct', category_id: DEFAULT_CATEGORY
      )

      # THEN: the service should report failure with an error message
      _(list_made.success?).must_equal false
      _(list_made.failure.message.downcase).must_include 'could not find'
    end
  end
end
