# frozen_string_literal: true

module Workouts
  # An exercise in a workout session
  class Exercise < ApplicationRecord
    belongs_to :session
    belongs_to :exercise_kind

    has_many :sets

    def as_json(*) = {
      id: id,
      kind: exercise_kind.kind,
      sets: sets.sort_by(&:created_at)
    }
  end
end
