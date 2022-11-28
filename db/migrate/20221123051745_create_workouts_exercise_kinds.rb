# frozen_string_literal: true

# Converts string-kinded exercise kind to a table
class CreateWorkoutsExerciseKinds < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts_exercise_kinds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind

      t.timestamps
    end

    remove_column :workouts_exercises, :kind, :string, null: false
    add_reference :workouts_exercises, :exercise_kind, null: false
  end
end
