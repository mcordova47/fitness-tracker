# frozen_string_literal: true

module Workouts
  # A workout session
  class Session < ApplicationRecord
    has_many :exercises

    def to_client_json
      {
        date: date,
        muscleGroup: muscle_group,
        exercises: exercises.map(&:to_client_json)
      }
    end
  end
end
