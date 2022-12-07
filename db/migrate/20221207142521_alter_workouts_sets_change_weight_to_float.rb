# frozen_string_literal: true

# Changes weight column of workouts_sets to a float
class AlterWorkoutsSetsChangeWeightToFloat < ActiveRecord::Migration[7.0]
  def up
    change_column :workouts_sets, :weight, :float, null: false
  end

  def down
    change_column :workouts_sets, :weight, :integer, null: false
  end
end
