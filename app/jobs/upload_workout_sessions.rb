# frozen_string_literal: true

require 'csv'

# Uploads sessions from a CSV
class UploadWorkoutSessions < ApplicationJob
  def perform(user, file_path) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    CSV.read(file_path, headers: true).each do |row|
      Workouts::Session.transaction do
        muscle_group = user.muscle_groups.find_or_create_by!(name: row['Muscle Group'])

        session = user.workout_sessions.find_or_create_by!(date: Date.strptime(row['Date'], '%m/%d/%y')) do |s|
          s.muscle_group = muscle_group
        end

        exercise_kind = user.exercise_kinds.find_or_create_by!(kind: row['Exercise'])
        exercise = session.exercises.create!(exercise_kind: exercise_kind)

        (1..5).each do |n|
          next unless row["Set #{n} Reps"].present? && row["Set #{n} Weight"].present?

          exercise.sets.create!(reps: row["Set #{n} Reps"], weight: row["Set #{n} Weight"])
        end
      end
    end
  end
end
