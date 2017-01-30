class CreateDefensivePlaySetChoices < ActiveRecord::Migration

  def change
    create_table :defensive_play_set_choices do |t|
      t.references :defensive_play_set, foreign_key: true
      t.references :defensive_play    , foreign_key: true
      t.integer    :weight

      t.timestamps null: false
    end

    add_index :defensive_play_set_choices, :defensive_play_set_id, name: 'def_choices_set'
    add_index :defensive_play_set_choices, :defensive_play_id    , name: 'def_choices_play'
  end
end
