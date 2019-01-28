class CreateGames < ActiveRecord::Migration[4.2]

  def change
    create_table :games do |t|
      t.integer :home_team_id                      , null: false
      t.integer :visitors_id                       , null: false
      t.integer :score_home      , default:  0     , null: false
      t.integer :score_visitors  , default:  0     , null: false
      t.integer :timeout_home    , default:  3     , null: false
      t.integer :timeout_visitors, default:  3     , null: false
      t.integer :quarter         , default:  1     , null: false
      t.integer :time_left       , default: 15 * 60, null: false
      t.boolean :clock_stopped   , default: true   , null: false
      t.boolean :home_has_ball   , default: true   , null: false
      t.integer :ball_on         , default: 35     , null: false
      t.integer :down            , default:  1     , null: false
      t.integer :yard_to_go      , default: 10     , null: false
      t.boolean :home_kicks_first, default: true   , null: false
      t.integer :next_play       , default:  0     , null: false
      t.integer :status          , default:  0     , null: false

      t.timestamps null: false
    end
  end
end
