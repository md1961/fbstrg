class CreateTeams < ActiveRecord::Migration

  def change
    create_table :teams do |t|
      t.string     :name, null: false
      t.references :offensive_play_strategy, index: true, foreign_key: true
      t.references :defensive_play_strategy, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
