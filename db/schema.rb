# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170130044721) do

  create_table "defensive_play_set_choices", force: :cascade do |t|
    t.integer  "defensive_play_set_id"
    t.integer  "defensive_play_id"
    t.integer  "weight"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "defensive_play_set_choices", ["defensive_play_id"], name: "def_choices_play"
  add_index "defensive_play_set_choices", ["defensive_play_set_id"], name: "def_choices_set"

  create_table "defensive_play_sets", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "defensive_plays", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "lineman",      null: false
    t.string   "linebacker",   null: false
    t.string   "cornerback",   null: false
    t.string   "safety",       null: false
    t.string   "against_run",  null: false
    t.string   "against_pass", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "defensive_strategies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_snapshots", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "play_id"
    t.integer  "score_home",       null: false
    t.integer  "score_visitors",   null: false
    t.integer  "timeout_home",     null: false
    t.integer  "timeout_visitors", null: false
    t.integer  "quarter",          null: false
    t.integer  "time_left",        null: false
    t.boolean  "home_has_ball",    null: false
    t.integer  "ball_on",          null: false
    t.integer  "down",             null: false
    t.integer  "yard_to_go",       null: false
    t.boolean  "home_kicks_first", null: false
    t.integer  "next_play",        null: false
    t.integer  "status",           null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "game_snapshots", ["game_id"], name: "index_game_snapshots_on_game_id"
  add_index "game_snapshots", ["play_id"], name: "index_game_snapshots_on_play_id"

  create_table "games", force: :cascade do |t|
    t.integer  "home_team_id",                    null: false
    t.integer  "visitors_id",                     null: false
    t.integer  "score_home",       default: 0,    null: false
    t.integer  "score_visitors",   default: 0,    null: false
    t.integer  "timeout_home",     default: 3,    null: false
    t.integer  "timeout_visitors", default: 3,    null: false
    t.integer  "quarter",          default: 1,    null: false
    t.integer  "time_left",        default: 900,  null: false
    t.boolean  "home_has_ball",    default: true, null: false
    t.integer  "ball_on",          default: 35,   null: false
    t.integer  "down",             default: 1,    null: false
    t.integer  "yard_to_go",       default: 10,   null: false
    t.boolean  "home_kicks_first", default: true, null: false
    t.integer  "next_play",        default: 0,    null: false
    t.integer  "status",           default: 0,    null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "offensive_play_set_choices", force: :cascade do |t|
    t.integer  "offensive_play_set_id"
    t.integer  "offensive_play_id"
    t.integer  "weight"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "offensive_play_set_choices", ["offensive_play_id"], name: "off_choices_play"
  add_index "offensive_play_set_choices", ["offensive_play_set_id"], name: "off_choices_set"

  create_table "offensive_play_sets", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offensive_plays", force: :cascade do |t|
    t.integer  "number",         null: false
    t.string   "name",           null: false
    t.integer  "min_throw_yard"
    t.integer  "max_throw_yard"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "offensive_strategies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "play_result_charts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "play_results", force: :cascade do |t|
    t.integer  "play_result_chart_id"
    t.integer  "offensive_play_id"
    t.integer  "defensive_play_id"
    t.string   "result",               null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "play_results", ["defensive_play_id"], name: "index_play_results_on_defensive_play_id"
  add_index "play_results", ["offensive_play_id"], name: "index_play_results_on_offensive_play_id"
  add_index "play_results", ["play_result_chart_id"], name: "index_play_results_on_play_result_chart_id"

  create_table "plays", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "team_id"
    t.integer  "number",                    default: 1,     null: false
    t.integer  "result",          limit: 1, default: 0,     null: false
    t.integer  "yardage",                   default: 0,     null: false
    t.integer  "fumble",          limit: 1, default: 0,     null: false
    t.boolean  "out_of_bounds",             default: false, null: false
    t.integer  "penalty",         limit: 1, default: 0,     null: false
    t.string   "penalty_name"
    t.integer  "penalty_yardage",           default: 0,     null: false
    t.boolean  "auto_firstdown",            default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "plays", ["game_id"], name: "index_plays_on_game_id"
  add_index "plays", ["team_id"], name: "index_plays_on_team_id"

  create_table "teams", force: :cascade do |t|
    t.string   "name",                  null: false
    t.string   "abbr",                  null: false
    t.integer  "play_result_chart_id"
    t.integer  "offensive_strategy_id"
    t.integer  "defensive_strategy_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "teams", ["defensive_strategy_id"], name: "index_teams_on_defensive_strategy_id"
  add_index "teams", ["offensive_strategy_id"], name: "index_teams_on_offensive_strategy_id"
  add_index "teams", ["play_result_chart_id"], name: "index_teams_on_play_result_chart_id"

end
