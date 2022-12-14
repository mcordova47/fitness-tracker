# frozen_string_literal: true

# Creates the measurements table
class CreateMeasurementsMeasurements < ActiveRecord::Migration[7.0]
  def change
    create_table :measurements_measurements do |t|
      t.float :value
      t.references :body_part, null: false, foreign_key: { to_table: :measurements_body_parts, on_delete: :cascade }
      t.date :date
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index :date, unique: true
    end
  end
end
