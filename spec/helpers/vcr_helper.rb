# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Helper for setting up VCR
class VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  OSM_CASSETE = 'osm_data_api'
  YOUTUBE_CASSETTE = 'youtube_api'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      c.ignore_localhost = true
      c.ignore_hosts 'sqs.us-east-1.amazonaws.com'
    end
  end

  def self.configure_vcr_for_osm
    VCR.insert_cassette(
      OSM_CASSETE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.configure_vcr_for_youtube(recording: :new_episodes)
    VCR.configure do |c|
      c.filter_sensitive_data('<GOOGLE_CLOUD_KEY>') { GOOGLE_CLOUD_KEY }
    end

    VCR.insert_cassette(
      YOUTUBE_CASSETTE,
      record: recording,
      match_requests_on: %i[method uri headers],
      allow_playback_repeats: true
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
