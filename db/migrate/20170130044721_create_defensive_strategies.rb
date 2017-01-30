class CreateDefensiveStrategies < ActiveRecord::Migration

  def change
    create_table :defensive_strategies do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
