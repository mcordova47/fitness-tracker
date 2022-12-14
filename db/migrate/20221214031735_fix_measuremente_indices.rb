# frozen_string_literal: true

# Fixes the unique indices on the measurements and body parts tables
class FixMeasurementeIndices < ActiveRecord::Migration[7.0]
  def change
    remove_index :measurements_measurements, :date, unique: true
    remove_index :measurements_body_parts, :name, unique: true
    add_index :measurements_measurements, %i[date body_part_id], unique: true
    add_index :measurements_body_parts, %i[name user_id], unique: true
  end
end
