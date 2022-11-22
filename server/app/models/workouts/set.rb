# frozen_string_literal: true

module Workouts
  # One set of a given exercise
  class Set < ApplicationRecord
    belongs_to :exercise

    def to_client_json(set_number:)
      {
        reps: reps,
        weight: weight,
        setNumber: set_number
      }
    end
  end
end
