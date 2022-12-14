# frozen_string_literal: true

module Workouts
  # One set of a given exercise
  class Set < ApplicationRecord
    belongs_to :exercise

    def as_json(*) = {
      id: id,
      reps: reps,
      weight: weight
    }
  end
end
