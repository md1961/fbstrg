class CreateOffensivePlayStrategies < ActiveRecord::Migration

  def change
    create_table :offensive_play_strategies do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
