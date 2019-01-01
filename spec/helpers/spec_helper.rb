# frozen_string_literal: false

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'

require 'pry' # for debugging

require_relative '../../init.rb'

COUNTRY_NAME = 'Taiwan'.freeze
REGION_CODE = 'tw'.freeze
DEFAULT_CATEGORY = 0
DEFAULT_MAX_RESULTS = 10

GOOGLE_CLOUD_KEY = YouTubeTrendingMap::Api.config.GOOGLE_CLOUD_KEY
VIDEO_CATEGORIES = YAML.safe_load(File.read('config/category.yml'))

CORRECT_OSM = YAML.safe_load(File.read('spec/fixtures/country_results.yml'))
CORRECT_YT = YAML.safe_load(File.read('spec/fixtures/trending_list_results.yml'))
