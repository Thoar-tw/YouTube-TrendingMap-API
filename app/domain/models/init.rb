# frozen_string_literal: true

folders = %w[hot_videos top_videos]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
