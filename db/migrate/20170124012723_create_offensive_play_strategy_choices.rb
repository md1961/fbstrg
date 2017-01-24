class CreateOffensivePlayStrategyChoices < ActiveRecord::Migration

  def change
    create_table :offensive_play_strategy_choices do |t|
      t.references :offensive_play_strategy, foreign_key: true
      t.references :offensive_play         , foreign_key: true
      t.integer    :weight

      t.timestamps null: false
    end

    add_index :offensive_play_strategy_choices, :offensive_play_strategy_id, name: 'off_choices_strategy'
    add_index :offensive_play_strategy_choices, :offensive_play_id         , name: 'off_choices_play'
  end
end
