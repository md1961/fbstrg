class CreateGames < ActiveRecord::Migration

  def change
    create_table :games do |t|
      t.integer :score_home      , default:  0
      t.integer :score_visitors  , default:  0
      t.integer :timeout_home    , default:  3
      t.integer :timeout_visitors, default:  3
      t.integer :quarter         , default:  1
      t.integer :time_left       , default: 15 * 60
      t.boolean :is_ball_to_home , default: true   , null: false
      t.integer :ball_on         , default: 35
      t.integer :down            , default:  1
      t.integer :yard_to_go      , default: 10

      t.timestamps null: false
    end
  end
end
