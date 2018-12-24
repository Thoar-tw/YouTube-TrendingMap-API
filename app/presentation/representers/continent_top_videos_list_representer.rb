# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'country_top_videos_list_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class ContinentTopVideosList < Roar::Decorator
      include Roar::JSON
      property :type
      property :count
      collection :videos, extend: Representer::CountryTopVideosList, class: OpenStruct
    end
  end
end
