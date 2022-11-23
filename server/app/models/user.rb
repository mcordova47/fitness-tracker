# frozen_string_literal: true

# A user in the system
class User < ApplicationRecord
  has_many :workout_sessions, class_name: '::Workouts::Session'
  has_many :exercise_kinds, class_name: '::Workouts::ExerciseKind'

  before_create do |u|
    u.slug = SecureRandom.base58(8)
  end
end
