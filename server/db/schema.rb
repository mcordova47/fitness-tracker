# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_11_21_215020) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "workouts_exercises", force: :cascade do |t|
    t.string "kind", null: false
    t.bigint "session_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_workouts_exercises_on_session_id"
  end

  create_table "workouts_sessions", force: :cascade do |t|
    t.date "date", null: false
    t.string "muscle_group", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "workouts_sets", force: :cascade do |t|
    t.integer "reps", null: false
    t.integer "weight", null: false
    t.bigint "exercise_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["exercise_id"], name: "index_workouts_sets_on_exercise_id"
  end

  add_foreign_key "workouts_exercises", "workouts_sessions", column: "session_id", on_delete: :cascade
  add_foreign_key "workouts_sets", "workouts_exercises", column: "exercise_id", on_delete: :cascade
end
