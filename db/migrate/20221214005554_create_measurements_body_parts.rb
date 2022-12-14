# frozen_string_literal: true

# Creates the body parts table
class CreateMeasurementsBodyParts < ActiveRecord::Migration[7.0]
  def change
    create_table :measurements_body_parts do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index :name, unique: true
    end
  end
end
