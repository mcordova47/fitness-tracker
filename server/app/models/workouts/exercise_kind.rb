# frozen_string_literal: true

module Workouts
  # Exercise types for a given user
  class ExerciseKind < ApplicationRecord
    belongs_to :user

    has_many :exercises
  end
end
