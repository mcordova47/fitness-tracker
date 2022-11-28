# frozen_string_literal: true

# Creates the users table and associates with workout sessions
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :slug, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_reference :workouts_sessions, :user, foreign_key: true, null: false
  end
end
