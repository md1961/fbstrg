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

ActiveRecord::Schema.define(version: 20170123230649) do

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

  create_table "games", force: :cascade do |t|
    t.integer  "score_home",       default: 0
    t.integer  "score_visitors",   default: 0
    t.integer  "timeout_home",     default: 3
    t.integer  "timeout_visitors", default: 3
    t.integer  "quarter",          default: 1
    t.integer  "time_left",        default: 900
    t.boolean  "is_ball_to_home",  default: true, null: false
    t.integer  "ball_on",          default: 35
    t.integer  "down",             default: 1
    t.integer  "yard_to_go",       default: 10
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "offensive_plays", force: :cascade do |t|
    t.integer  "number",     null: false
    t.string   "name",       null: false
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

end
