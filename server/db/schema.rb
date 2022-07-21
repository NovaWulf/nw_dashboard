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

ActiveRecord::Schema.define(version: 2022_07_21_004750) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "candles", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "starttime", null: false
    t.string "pair", null: false
    t.string "exchange", null: false
    t.integer "resolution", null: false
    t.float "open", null: false
    t.float "close", null: false
    t.float "high", null: false
    t.float "low", null: false
    t.float "volume", null: false
    t.index ["exchange", "starttime", "pair", "resolution"], name: "index_candles_on_exchange_and_starttime_and_pair_and_resolution", unique: true
  end

  create_table "cointegration_model_weights", force: :cascade do |t|
    t.string "uuid"
    t.integer "timestamp"
    t.string "asset_name"
    t.float "weight"
    t.index ["uuid", "asset_name"], name: "index_cointegration_model_weights_on_uuid_and_asset_name", unique: true
  end

  create_table "cointegration_models", force: :cascade do |t|
    t.string "uuid"
    t.integer "timestamp"
    t.string "ecdet"
    t.string "spec"
    t.float "cv_10_pct"
    t.float "cv_5_pct"
    t.float "cv_1_pct"
    t.float "test_stat"
    t.float "top_eig"
    t.float "in_sample_mean"
    t.float "in_sample_sd"
    t.integer "resolution"
    t.integer "model_starttime"
    t.integer "model_endtime"
    t.index ["uuid"], name: "index_cointegration_models_on_uuid", unique: true
  end

  create_table "metrics", force: :cascade do |t|
    t.date "timestamp"
    t.float "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "token"
    t.string "metric"
  end

  create_table "modeled_signals", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "starttime", null: false
    t.string "model_id", null: false
    t.integer "resolution", null: false
    t.float "value", null: false
    t.boolean "in_sample", default: true
    t.index ["model_id", "starttime"], name: "index_modeled_signals_on_model_id_and_starttime", unique: true
  end

  create_table "repo_commits", force: :cascade do |t|
    t.date "day"
    t.integer "count"
    t.bigint "repo_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["repo_id", "day"], name: "index_repo_commits_on_repo_id_and_day", unique: true
    t.index ["repo_id"], name: "index_repo_commits_on_repo_id"
  end

  create_table "repos", force: :cascade do |t|
    t.string "token"
    t.string "user"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "backfilled_at"
    t.datetime "last_fetched_at"
    t.datetime "error_fetching_at"
    t.integer "github_id"
    t.boolean "canonical", default: false
    t.index ["user", "name", "token"], name: "index_repos_on_user_and_name_and_token", unique: true
  end

  add_foreign_key "repo_commits", "repos"
end
