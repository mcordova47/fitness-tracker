# frozen_string_literal: true

# A user in the system
class User < ApplicationRecord
  has_many :workout_sessions, class_name: '::Workouts::Session'
  has_many :exercise_kinds, class_name: '::Workouts::ExerciseKind'
  has_many :muscle_groups, class_name: '::Workouts::MuscleGroup'
  has_many :body_parts, class_name: '::Measurements::BodyPart'
  has_many :measurements, class_name: '::Measurements::Measurement'

  before_create do |u|
    u.slug = SecureRandom.base58(8)
  end
end
