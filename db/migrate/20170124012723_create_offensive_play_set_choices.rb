class CreateOffensivePlaySetChoices < ActiveRecord::Migration[4.2]

  def change
    create_table :offensive_play_set_choices do |t|
      t.references :offensive_play_set, foreign_key: true
      t.references :offensive_play    , foreign_key: true
      t.integer    :weight

      t.timestamps null: false
    end

    add_index :offensive_play_set_choices, :offensive_play_set_id, name: 'off_choices_set'
    add_index :offensive_play_set_choices, :offensive_play_id    , name: 'off_choices_play'
  end
end
