class CreateDefensivePlaySets < ActiveRecord::Migration

  def change
    create_table :defensive_play_sets do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
