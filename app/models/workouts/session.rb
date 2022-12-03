# frozen_string_literal: true

module Workouts
  # A workout session
  class Session < ApplicationRecord
    belongs_to :user
    belongs_to :muscle_group

    has_many :exercises

    def as_json(*)
      {
        id: id,
        date: date,
        muscleGroup: muscle_group,
        exercises: exercises
      }
    end
  end
end
