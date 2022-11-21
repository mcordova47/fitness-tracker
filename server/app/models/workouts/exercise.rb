# frozen_string_literal: true

module Workouts
  class Exercise < ApplicationRecord
    belongs_to :session

    has_many :sets
  end
end
