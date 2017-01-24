class CreateOffensivePlayStrategyWeights < ActiveRecord::Migration

  def change
    create_table :offensive_play_strategy_weights do |t|
      t.references :offensive_play_strategy, foreign_key: true
      t.references :offensive_play         , foreign_key: true
      t.integer    :weight

      t.timestamps null: false
    end

    add_index :offensive_play_strategy_weights, :offensive_play_strategy_id, name: 'off_weights_strategy'
    add_index :offensive_play_strategy_weights, :offensive_play_id         , name: 'off_weights_play'
  end
end
