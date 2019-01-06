# frozen_string_literal: true

require_relative '../init.rb'

require 'econfig'
require 'shoryuken'
require 'json'

# Shoryuken worker class to retrieve top videos from countries in parallel
class VideoBatchAdditionWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.ADDITION_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    data_arr = JSON.parse(request)['videos']
    data_arr.each do |data|
      video = build_entity(data)

      YouTubeTrendingMap::FavoriteVideosRepository::For
        .entity(video).find_or_create(video)
        .yield_self { |result| puts result }
    end
  rescue StandardError => error
    puts error
    puts error.backtrace.join("\n")
  end

  def build_entity(input)
    YouTubeTrendingMap::Entity::FavoriteVideo.new(
      origin_id: input['origin_id'],
      title: input['title'],
      channel_title: input['channel_title'],
      view_count: input['view_count'].to_i,
      embed_link: input['embed_link']
    )
  end
end
