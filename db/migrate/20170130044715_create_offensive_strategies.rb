class CreateOffensiveStrategies < ActiveRecord::Migration

  def change
    create_table :offensive_strategies do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
