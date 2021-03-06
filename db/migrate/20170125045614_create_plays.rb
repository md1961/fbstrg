class CreatePlays < ActiveRecord::Migration[4.2]

  def change
    create_table :plays do |t|
      t.references :game, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true
      t.integer :number         , null: false, default: 1
      t.integer :result         , null: false, default: 0, limit: 1
      t.integer :yardage        , null: false, default: 0
      t.integer :fumble         , null: false, default: 0, limit: 1
      t.boolean :out_of_bounds  , null: false, default: false
      t.integer :penalty        , null: false, default: 0, limit: 1
      t.string  :penalty_name
      t.integer :penalty_yardage, null: false, default: 0
      t.boolean :auto_firstdown , null: false, default: false
      t.integer :air_yardage    , null: false, default: 0
      t.references :offensive_play    , index: true, foreign_key: true
      t.references :offensive_play_set, index: true, foreign_key: true
      t.references :defensive_play    , index: true, foreign_key: true
      t.references :defensive_play_set, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
