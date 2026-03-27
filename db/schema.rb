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

ActiveRecord::Schema[8.1].define(version: 2026_03_27_230807) do
  create_table "repositories", force: :cascade do |t|
    t.boolean "cocina_models_update", default: false, null: false
    t.datetime "created_at", null: false
    t.text "exclude_envs"
    t.date "last_updated"
    t.string "name", null: false
    t.text "non_standard_envs"
    t.boolean "skip_audit", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_repositories_on_name", unique: true
  end

  create_table "system_statuses", force: :cascade do |t|
    t.boolean "connected", default: false, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_system_statuses_on_name", unique: true
  end

  create_table "update_pull_requests", force: :cascade do |t|
    t.integer "build", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "pull_request", null: false
    t.integer "repository_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["pull_request"], name: "index_update_pull_requests_on_pull_request", unique: true
    t.index ["repository_id"], name: "index_update_pull_requests_on_repository_id"
  end

  add_foreign_key "update_pull_requests", "repositories"
end
