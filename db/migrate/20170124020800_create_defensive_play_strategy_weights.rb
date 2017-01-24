class CreateDefensivePlayStrategyWeights < ActiveRecord::Migration

  def change
    create_table :defensive_play_strategy_weights do |t|
      t.references :defensive_play_strategy, foreign_key: true
      t.references :defensive_play         , foreign_key: true
      t.integer    :weight

      t.timestamps null: false
    end

    add_index :defensive_play_strategy_weights, :defensive_play_strategy_id, name: 'def_weights_strategy'
    add_index :defensive_play_strategy_weights, :defensive_play_id         , name: 'def_weights_play'
  end
end
