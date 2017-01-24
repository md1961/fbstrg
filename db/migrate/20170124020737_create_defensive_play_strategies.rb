class CreateDefensivePlayStrategies < ActiveRecord::Migration

  def change
    create_table :defensive_play_strategies do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
