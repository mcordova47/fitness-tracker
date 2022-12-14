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

ActiveRecord::Schema[7.0].define(version: 2022_12_14_010453) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "measurements_body_parts", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_measurements_body_parts_on_name", unique: true
    t.index ["user_id"], name: "index_measurements_body_parts_on_user_id"
  end

  create_table "measurements_measurements", force: :cascade do |t|
    t.float "value"
    t.bigint "body_part_id", null: false
    t.date "date"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["body_part_id"], name: "index_measurements_measurements_on_body_part_id"
    t.index ["date"], name: "index_measurements_measurements_on_date", unique: true
    t.index ["user_id"], name: "index_measurements_measurements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workouts_exercise_kinds", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workouts_exercise_kinds_on_user_id"
  end

  create_table "workouts_exercises", force: :cascade do |t|
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "exercise_kind_id", null: false
    t.index ["exercise_kind_id"], name: "index_workouts_exercises_on_exercise_kind_id"
    t.index ["session_id"], name: "index_workouts_exercises_on_session_id"
  end

  create_table "workouts_muscle_groups", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workouts_muscle_groups_on_user_id"
  end

  create_table "workouts_sessions", force: :cascade do |t|
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "muscle_group_id", null: false
    t.index ["muscle_group_id"], name: "index_workouts_sessions_on_muscle_group_id"
    t.index ["user_id"], name: "index_workouts_sessions_on_user_id"
  end

  create_table "workouts_sets", force: :cascade do |t|
    t.integer "reps", null: false
    t.float "weight", null: false
    t.bigint "exercise_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_workouts_sets_on_exercise_id"
  end

  add_foreign_key "measurements_body_parts", "users"
  add_foreign_key "measurements_measurements", "measurements_body_parts", column: "body_part_id", on_delete: :cascade
  add_foreign_key "measurements_measurements", "users"
  add_foreign_key "workouts_exercise_kinds", "users"
  add_foreign_key "workouts_exercises", "workouts_sessions", column: "session_id", on_delete: :cascade
  add_foreign_key "workouts_sessions", "users"
  add_foreign_key "workouts_sets", "workouts_exercises", column: "exercise_id", on_delete: :cascade
end
