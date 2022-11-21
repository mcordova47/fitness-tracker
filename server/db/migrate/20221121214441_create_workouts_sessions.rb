# frozen_string_literal: true

# Creates the workout sessions table
class CreateWorkoutsSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts_sessions do |t|
      t.date :date, null: false
      t.string :muscle_group, null: false

      t.timestamps
    end
  end
end
