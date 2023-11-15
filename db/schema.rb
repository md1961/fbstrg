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

ActiveRecord::Schema.define(version: 2023_11_15_001224) do

  create_table "defensive_play_set_choices", force: :cascade do |t|
    t.integer "defensive_play_set_id"
    t.integer "defensive_play_id"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["defensive_play_id"], name: "def_choices_play"
    t.index ["defensive_play_set_id"], name: "def_choices_set"
  end

  create_table "defensive_play_sets", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "defensive_plays", force: :cascade do |t|
    t.string "name", null: false
    t.string "lineman", null: false
    t.string "linebacker", null: false
    t.string "cornerback", null: false
    t.string "safety", null: false
    t.string "against_run", null: false
    t.string "against_pass", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "defensive_strategies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_snapshots", force: :cascade do |t|
    t.integer "game_id"
    t.integer "play_id"
    t.integer "score_home", null: false
    t.integer "score_visitors", null: false
    t.integer "timeout_home", null: false
    t.integer "timeout_visitors", null: false
    t.integer "quarter", null: false
    t.integer "time_left", null: false
    t.boolean "clock_stopped", null: false
    t.boolean "home_has_ball", null: false
    t.integer "ball_on", null: false
    t.integer "down", null: false
    t.integer "yard_to_go", null: false
    t.boolean "home_kicks_first", null: false
    t.integer "next_play", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_snapshots_on_game_id"
    t.index ["play_id"], name: "index_game_snapshots_on_play_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "home_team_id", null: false
    t.integer "visitors_id", null: false
    t.integer "score_home", default: 0, null: false
    t.integer "score_visitors", default: 0, null: false
    t.integer "timeout_home", default: 3, null: false
    t.integer "timeout_visitors", default: 3, null: false
    t.integer "quarter", default: 1, null: false
    t.integer "time_left", default: 900, null: false
    t.boolean "clock_stopped", default: true, null: false
    t.boolean "home_has_ball", default: true, null: false
    t.integer "ball_on", default: 35, null: false
    t.integer "down", default: 1, null: false
    t.integer "yard_to_go", default: 10, null: false
    t.boolean "home_kicks_first", default: true, null: false
    t.integer "next_play", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_neutral", default: false, null: false
  end

  create_table "offensive_play_set_choices", force: :cascade do |t|
    t.integer "offensive_play_set_id"
    t.integer "offensive_play_id"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offensive_play_id"], name: "off_choices_play"
    t.index ["offensive_play_set_id"], name: "off_choices_set"
  end

  create_table "offensive_play_sets", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offensive_plays", force: :cascade do |t|
    t.integer "number", null: false
    t.string "name", null: false
    t.integer "min_throw_yard"
    t.integer "max_throw_yard"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offensive_strategies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "play_result_charts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "play_results", force: :cascade do |t|
    t.integer "play_result_chart_id"
    t.integer "offensive_play_id"
    t.integer "defensive_play_id"
    t.string "result", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["defensive_play_id"], name: "index_play_results_on_defensive_play_id"
    t.index ["offensive_play_id"], name: "index_play_results_on_offensive_play_id"
    t.index ["play_result_chart_id"], name: "index_play_results_on_play_result_chart_id"
  end

  create_table "playoff_berths", force: :cascade do |t|
    t.integer "team_group_id", null: false
    t.integer "team_id", null: false
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_group_id", "team_id"], name: "index_playoff_berths_on_team_group_id_and_team_id", unique: true
    t.index ["team_group_id"], name: "index_playoff_berths_on_team_group_id"
    t.index ["team_id"], name: "index_playoff_berths_on_team_id"
  end

  create_table "plays", force: :cascade do |t|
    t.integer "game_id"
    t.integer "team_id"
    t.integer "number", default: 1, null: false
    t.integer "result", limit: 1, default: 0, null: false
    t.integer "yardage", default: 0, null: false
    t.integer "fumble", limit: 1, default: 0, null: false
    t.boolean "out_of_bounds", default: false, null: false
    t.integer "penalty", limit: 1, default: 0, null: false
    t.string "penalty_name"
    t.integer "penalty_yardage", default: 0, null: false
    t.boolean "auto_firstdown", default: false, null: false
    t.integer "air_yardage", default: 0, null: false
    t.integer "offensive_play_id"
    t.integer "offensive_play_set_id"
    t.integer "defensive_play_id"
    t.integer "defensive_play_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "scoring", limit: 1, default: 0, null: false
    t.index ["defensive_play_id"], name: "index_plays_on_defensive_play_id"
    t.index ["defensive_play_set_id"], name: "index_plays_on_defensive_play_set_id"
    t.index ["game_id"], name: "index_plays_on_game_id"
    t.index ["offensive_play_id"], name: "index_plays_on_offensive_play_id"
    t.index ["offensive_play_set_id"], name: "index_plays_on_offensive_play_set_id"
    t.index ["team_id"], name: "index_plays_on_team_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "team_group_id"
    t.integer "week", null: false
    t.integer "number", null: false
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_playoff", default: false, null: false
    t.index ["game_id"], name: "index_schedules_on_game_id"
    t.index ["team_group_id"], name: "index_schedules_on_team_group_id"
  end

  create_table "team_groups", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.string "abbr"
    t.integer "year", null: false
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_traits", force: :cascade do |t|
    t.integer "team_id"
    t.integer "run_yardage", default: 0, null: false
    t.integer "run_breakaway", default: 0, null: false
    t.integer "pass_short", default: 0, null: false
    t.integer "pass_long", default: 0, null: false
    t.integer "pass_breakaway", default: 0, null: false
    t.integer "pass_protect", default: 0, null: false
    t.integer "qb_mobility", default: 0, null: false
    t.integer "run_defense", default: 0, null: false
    t.integer "run_tackling", default: 0, null: false
    t.integer "pass_rush", default: 0, null: false
    t.integer "pass_coverage", default: 0, null: false
    t.integer "pass_tackling", default: 0, null: false
    t.integer "place_kicking", default: 0, null: false
    t.integer "return_breakaway", default: 0, null: false
    t.integer "return_coverage", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "qb_read", default: 0, null: false
    t.index ["team_id"], name: "index_team_traits_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.string "abbr", null: false
    t.integer "play_result_chart_id"
    t.integer "offensive_strategy_id"
    t.integer "defensive_strategy_id"
    t.integer "team_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["defensive_strategy_id"], name: "index_teams_on_defensive_strategy_id"
    t.index ["offensive_strategy_id"], name: "index_teams_on_offensive_strategy_id"
    t.index ["play_result_chart_id"], name: "index_teams_on_play_result_chart_id"
    t.index ["team_group_id"], name: "index_teams_on_team_group_id"
  end

end
