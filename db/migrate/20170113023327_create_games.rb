class CreateGames < ActiveRecord::Migration

  def change
    create_table :games do |t|
      t.integer :home_id         , default:  1     , null: false
      t.integer :visitors_id     , default:  1     , null: false
      t.integer :score_home      , default:  0     , null: false
      t.integer :score_visitors  , default:  0     , null: false
      t.integer :timeout_home    , default:  3     , null: false
      t.integer :timeout_visitors, default:  3     , null: false
      t.integer :quarter         , default:  1     , null: false
      t.integer :time_left       , default: 15 * 60, null: false
      t.boolean :is_ball_to_home , default: true   , null: false
      t.integer :ball_on         , default: 35     , null: false
      t.integer :down            , default:  1     , null: false
      t.integer :yard_to_go      , default: 10     , null: false

      t.timestamps null: false
    end
  end
end
