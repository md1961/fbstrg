class CreateOffensivePlaySets < ActiveRecord::Migration

  def change
    create_table :offensive_play_sets do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
