# frozen_string_literal: true

# Creates the sets table
class CreateWorkoutsSets < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts_sets do |t|
      t.integer :reps, null: false
      t.integer :weight, null: false
      t.references :exercise, null: false, foreign_key: { to_table: :workouts_exercises, on_delete: :cascade }

      t.timestamps
    end
  end
end
