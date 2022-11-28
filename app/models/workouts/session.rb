# frozen_string_literal: true

module Workouts
  # A workout session
  class Session < ApplicationRecord
    belongs_to :user

    has_many :exercises

    def as_json(*)
      {
        date: date,
        muscleGroup: muscle_group,
        exercises: exercises
      }
    end
  end
end
