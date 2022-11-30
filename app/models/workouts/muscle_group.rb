# frozen_string_literal: true

module Workouts
  # A muscle group (each session is for a given muscle group)
  class MuscleGroup < ApplicationRecord
    belongs_to :user

    has_many :sessions

    def as_json(*)
      { name: name }
    end
  end
end
