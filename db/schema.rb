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

ActiveRecord::Schema[8.1].define(version: 2026_03_28_235622) do
  create_table "deployments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "date", null: false
    t.integer "environment", null: false
    t.integer "repository_id", null: false
    t.string "revision", null: false
    t.datetime "updated_at", null: false
    t.string "user", null: false
    t.index ["repository_id", "revision", "environment"], name: "index_deployments_on_repo_revision_env", unique: true
    t.index ["repository_id"], name: "index_deployments_on_repository_id"
  end

  create_table "faults", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "date", null: false
    t.integer "environment", null: false
    t.string "honeybadger_id", null: false
    t.integer "repository_id", null: false
    t.string "revision", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["honeybadger_id"], name: "index_faults_on_honeybadger_id", unique: true
    t.index ["repository_id"], name: "index_faults_on_repository_id"
  end

  create_table "integration_tests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_integration_tests_on_name", unique: true
  end

  create_table "repositories", force: :cascade do |t|
    t.boolean "cocina_models_update", default: false, null: false
    t.datetime "created_at", null: false
    t.text "exclude_envs"
    t.date "last_updated"
    t.string "name", null: false
    t.text "non_standard_envs"
    t.string "project_id"
    t.boolean "skip_audit", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_repositories_on_name", unique: true
  end

  create_table "system_statuses", force: :cascade do |t|
    t.boolean "connected", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_system_statuses_on_name", unique: true
  end

  create_table "test_runs", force: :cascade do |t|
    t.string "collection_druid"
    t.datetime "created_at", null: false
    t.string "druid"
    t.integer "duration"
    t.integer "integration_test_id", null: false
    t.text "output"
    t.string "status", default: "queuing", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_test_id"], name: "index_test_runs_on_integration_test_id"
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

  add_foreign_key "deployments", "repositories"
  add_foreign_key "faults", "repositories"
  add_foreign_key "test_runs", "integration_tests"
  add_foreign_key "update_pull_requests", "repositories"
end
