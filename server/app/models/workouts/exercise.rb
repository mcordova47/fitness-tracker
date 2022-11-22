# frozen_string_literal: true

module Workouts
  # An exercise in a workout session
  class Exercise < ApplicationRecord
    belongs_to :session

    has_many :sets

    def to_client_json
      {
        kind: kind,
        sets: sets.order(:created_at).map.with_index { |s, i| s.to_client_json(set_number: i + 1) }
      }
    end
  end
end
