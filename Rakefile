# frozen_string_literal: true

require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'Run unit and integration tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'Run acceptance tests'
Rake::TestTask.new(:spec_accept) do |t|
  puts 'NOTE: run `rake run:test` in another process'
  t.pattern = 'spec/tests_acceptance/*.rb'
  t.warning = false
end

desc 'Keep rerunning unit/integration tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Keep restarting app server upon changes'
task :rerack do
  sh "rerun -c rackup --ignore 'coverage/*'"
end

namespace :run do
  task :dev do
    sh 'rerun -c "rackup -p 9292"'
  end

  task :test do
    sh 'RACK_ENV=test rackup -p 9090'
  end
end

namespace :queues do
  task :config do
    require 'aws-sdk-sqs'
    require_relative 'config/environment.rb' # load config info
    @api = YouTubeTrendingMap::Api

    @sqs = Aws::SQS::Client.new(
      access_key_id: @api.config.AWS_ACCESS_KEY_ID,
      secret_access_key: @api.config.AWS_SECRET_ACCESS_KEY,
      region: @api.config.AWS_REGION
    )
  end

  desc 'Create SQS queue for Shoryuken'
  task create: :config do
    puts "Environment: #{@api.environment}"
    @sqs.create_queue(queue_name: @api.config.ADDITION_QUEUE)

    q_url = @sqs.get_queue_url(queue_name: @api.config.ADDITION_QUEUE).queue_url
    puts 'Queue created:'
    puts "  Name: #{@api.config.ADDITION_QUEUE}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{q_url}"
  rescue StandardError => error
    puts "Error creating queue: #{error}"
  end

  desc 'Purge messages in SQS queue for Shoryuken'
  task purge: :config do
    q_url = @sqs.get_queue_url(queue_name: @api.config.ADDITION_QUEUE).queue_url
    @sqs.purge_queue(queue_url: q_url)
    puts "Queue #{queue_name} purged"
  rescue StandardError => error
    puts "Error purging queue: #{error}"
  end
end

# rubocop:disable Metrics/LineLength
namespace :worker do
  namespace :run do
    desc 'Run the background cloning worker in development mode'
    task development: :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/video_batch_addition_worker.rb -C ./workers/shoryuken_dev.yml'
    end

    desc 'Run the background cloning worker in testing mode'
    task test: :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/video_batch_addition_worker.rb -C ./workers/shoryuken_test.yml'
    end

    desc 'Run the background cloning worker in production mode'
    task production: :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/video_batch_addition_worker.rb -C ./workers/shoryuken.yml'
    end
  end
end
# rubocop:enable Metrics/LineLength

namespace :cache do
  task :config do
    require_relative 'config/environment.rb' # load config info
    require_relative 'app/infrastructure/cache/init.rb' # load cache client
    @api = YouTubeTrendingMap::Api
  end

  namespace :list do
    task :dev do
      puts 'Finding development cache'
      list = `ls _cache`
      puts 'No local cache found' if list.empty?
      puts list
    end

    task production: :config do
      puts 'Finding production cache'
      keys = YouTubeTrendingMap::Cache::Client.new(@api.config).keys
      puts 'No keys found' if keys.none?
      keys.each { |key| puts "Key: #{key}" }
    end
  end

  namespace :wipe do
    task :dev do
      puts 'Deleting development cache'
      sh 'rm -rf _cache/*'
    end

    task production: :config do
      print 'Are you sure you wish to wipe the production cache? (y/n) '
      if STDIN.gets.chomp.downcase == 'y'
        puts 'Deleting production cache'
        wiped = YouTubeTrendingMap::Cache::Client.new(@api.config).wipe
        wiped.keys.each { |key| puts "Wiped: #{key}" }
      end
    end
  end
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment.rb' # load config info
    @api = YouTubeTrendingMap::Api
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{@api.environment} database to latest"
    Sequel::Migrator.run(@api.DB, 'app/infrastructure/database/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    require_relative 'spec/helpers/database_helper.rb'
    DatabaseHelper.setup_database_cleaner
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file'
  task drop: :config do
    if @api.environment == :production
      puts 'Cannot remove production database'
      return
    end

    FileUtils.rm(@api.config.DB_FILENAME)
    puts "Deleted #{@api.config.DB_FILENAME}"
  end
end

desc 'Run application console (pry)'
task :console do
  sh 'pry -r ./init.rb'
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  CODE = 'app'

  desc 'run all quality checks'
  task all: %i[rubocop flog reek]

  task :rubocop do
    sh 'rubocop'
  end

  task :flog do
    sh "flog #{CODE}"
  end

  task :reek do
    sh "reek #{CODE}"
  end
end
