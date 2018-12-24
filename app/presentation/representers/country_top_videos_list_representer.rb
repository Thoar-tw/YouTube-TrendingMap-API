# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class CountryTopVideosList < Roar::Decorator
      include Roar::JSON
      property :type
      property :count
      collection :videos, extend: Representer::ContinentTopVideosList, class: OpenStruct
    end
  end
end
