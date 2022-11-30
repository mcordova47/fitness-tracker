# frozen_string_literal: true

# Creates a separate table for muscle groups
class CreateWorkoutsMuscleGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts_muscle_groups do |t|
      t.string :name, null: false
      t.references :user

      t.timestamps
    end

    remove_column :workouts_sessions, :muscle_group, :string, null: false
    add_reference :workouts_sessions, :muscle_group, null: false
  end
end
