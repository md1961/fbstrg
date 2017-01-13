class CreateGames < ActiveRecord::Migration

  def change
    create_table :games do |t|
      t.integer :score_home    , default: 0
      t.integer :score_visitors, default: 0
      t.integer :timeout_home
      t.integer :timeout_visitors
      t.integer :quarter
      t.integer :time_left
      t.boolean :is_ball_to_home, null: false
      t.integer :ball_on
      t.integer :down
      t.integer :yard_to_go

      t.timestamps null: false
    end
  end
end
