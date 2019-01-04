# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.3'

# PRESENTATION LAYER
gem 'multi_json'
gem 'roar'

# APPLICATION LAYER
# Web application
gem 'econfig', '~> 2.1'
gem 'rack', '~> 2.0.6'
gem 'puma', '~> 3.12'
gem 'rack-cache', '~> 1.8'
gem 'redis', '~> 4.1'
gem 'redis-rack-cache', '~> 2.0'
gem 'roda', '~> 3.15'

# Controllers and services
gem 'dry-monads'
gem 'dry-transaction'
gem 'dry-validation'

# DOMAIN LAYER
# Entity
gem 'dry-struct', '~> 0.5'
gem 'dry-types', '~> 0.13'

# INFRASTRUCTURE LAYER
# Database
gem 'hirb'
gem 'sequel'

group :development, :test do
  gem 'database_cleaner'
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end

# Networking
gem 'http', '~> 4.0'

# TESTING
group :test do
  gem 'headless', '~> 2.3'
  gem 'minitest', '~> 5.11'
  gem 'minitest-rg', '~> 5.0'
  gem 'page-object', '~> 2.2'
  gem 'simplecov', '~> 0.16'
  gem 'vcr', '~> 4.0'
  gem 'webmock', '~> 3.4'
  gem 'watir', '~> 6.15'
end

gem 'rack-test' # can also be used to diagnose production

# QUALITY
group :development, :test do
  gem 'flog'
  gem 'reek'
  gem 'rubocop', '~> 0.61'
end

# UTILITIES
gem 'rake'
gem 'pry', '~> 0.11'

group :development, :test do
  gem 'rerun', '~> 0.13'
end
