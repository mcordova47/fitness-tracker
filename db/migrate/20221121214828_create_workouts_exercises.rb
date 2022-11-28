# frozen_string_literal: true

# Creates the exercises table
class CreateWorkoutsExercises < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts_exercises do |t|
      t.string :kind, null: false
      t.references :session, null: false, foreign_key: { to_table: :workouts_sessions, on_delete: :cascade }

      t.timestamps
    end
  end
end
