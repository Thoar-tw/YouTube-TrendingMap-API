# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'
require_relative '../helpers/vcr_helper.rb'
require_relative '../helpers/database_helper.rb'
require 'rack/test'

def app
  YouTubeTrendingMap::Api
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_youtube(recording: :none)
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)
      _(result['status']).must_equal 'ok'
      _(result['message']).must_include 'api/v1'
    end
  end

  describe 'Get hot videos list route' do
    it 'should be able to get a list of hot videos' do
      YouTubeTrendingMap::Services::GetHotVideosList.new.call(
        region_code: REGION_CODE, category_id: DEFAULT_CATEGORY
      )

      post "/api/v1/hot_videos/#{REGION_CODE}/#{DEFAULT_CATEGORY}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body

      _(result.keys.sort).must_equal %w[belonging_country count videos]
      _(result['count']).must_equal 10
      _(result['belonging_country']).must_equal COUNTRY_NAME

      video = result['videos'].first
      _(video['origin_id']).wont_be_nil
      _(video['title']).wont_be_nil
      _(video['description']).wont_be_nil
      _(video['channel_title']).wont_be_nil
      _(video['view_count']).wont_be_nil
      _(video['like_count']).wont_be_nil
      _(video['dislike_count']).wont_be_nil
      _(video['embed_link']).wont_be_nil
    end

    it 'should report error for invalid region code' do
      post 'api/v1/hot_videos/ct/1'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get global top videos list route' do
    it 'should be able to get a list of global top videos' do
      YouTubeTrendingMap::Services::GetGlobalTopVideosList.new.call(
        category_id: DEFAULT_CATEGORY
      )

      post "/api/v1/top_videos/global/#{DEFAULT_CATEGORY}"
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body

      _(result.keys.sort).must_equal %w[count type videos]

      video = result['videos'].first
      _(video['origin_id']).wont_be_nil
      _(video['title']).wont_be_nil
      _(video['description']).wont_be_nil
      _(video['channel_title']).wont_be_nil
      _(video['view_count']).wont_be_nil
      _(video['like_count']).wont_be_nil
      _(video['dislike_count']).wont_be_nil
      _(video['embed_link']).wont_be_nil
    end

    it 'should report error for invalid cateogory id' do
      post 'api/v1/top_videos/global/45'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get favorite videos list route' do
    it 'should successfully return favorite list' do
      YouTubeTrendingMap::Services::ListFavoriteVideos.new.call

      get '/api/v1/favorite_videos'
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      projects = response['projects']
      _(projects.count).must_equal 1
      project = projects.first
      _(project['name']).must_equal PROJECT_NAME
      _(project['owner']['username']).must_equal USERNAME
      _(project['contributors'].count).must_equal 3
    end
    it 'should return error if no favorite videos list provided' do
      get '/api/v1/favorite_videos'
      _(last_response.status).must_equal 400

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'list'
    end
  end
end
