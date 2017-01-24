class CreateDefensivePlayStrategyChoices < ActiveRecord::Migration

  def change
    create_table :defensive_play_strategy_choices do |t|
      t.references :defensive_play_strategy, foreign_key: true
      t.references :defensive_play         , foreign_key: true
      t.integer    :weight

      t.timestamps null: false
    end

    add_index :defensive_play_strategy_choices, :defensive_play_strategy_id, name: 'def_choices_strategy'
    add_index :defensive_play_strategy_choices, :defensive_play_id         , name: 'def_choices_play'
  end
end
