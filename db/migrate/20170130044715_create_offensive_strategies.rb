class CreateOffensiveStrategies < ActiveRecord::Migration[4.2]

  def change
    create_table :offensive_strategies do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
