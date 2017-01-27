class CreateGameSnapshots < ActiveRecord::Migration

  def change
    create_table :game_snapshots do |t|
      t.references :game, index: true, foreign_key: true
      t.integer :score_home      , null: false
      t.integer :score_visitors  , null: false
      t.integer :timeout_home    , null: false
      t.integer :timeout_visitors, null: false
      t.integer :quarter         , null: false
      t.integer :time_left       , null: false
      t.boolean :is_ball_to_home , null: false
      t.integer :ball_on         , null: false
      t.integer :down            , null: false
      t.integer :yard_to_go      , null: false
      t.integer :next_play       , null: false

      t.timestamps null: false
    end
  end
end
