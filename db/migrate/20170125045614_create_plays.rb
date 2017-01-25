class CreatePlays < ActiveRecord::Migration

  def change
    create_table :plays do |t|
      t.references :game, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true
      t.integer :result         , null: false, default: 0, limit: 1
      t.integer :yardage        , null: false, default: 0
      t.integer :fumble         , null: false, default: 0, limit: 1
      t.boolean :out_of_bounds  , null: false, default: false
      t.integer :penalty        , null: false, default: 0, limit: 1
      t.string  :penalty_name
      t.integer :penalty_yardage, null: false, default: 0

      t.timestamps null: false
    end
  end
end
