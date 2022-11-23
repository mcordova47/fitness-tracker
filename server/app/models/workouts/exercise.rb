# frozen_string_literal: true

module Workouts
  # An exercise in a workout session
  class Exercise < ApplicationRecord
    belongs_to :session

    has_many :sets

    def as_json(*)
      {
        kind: kind,
        sets: sets.order(:created_at)
      }
    end
  end
end