class CreateTeams < ActiveRecord::Migration[4.2]

  def change
    create_table :teams do |t|
      t.string     :name, null: false
      t.string     :abbr, null: false
      t.references :play_result_chart , index: true, foreign_key: true
      t.references :offensive_strategy, index: true, foreign_key: true
      t.references :defensive_strategy, index: true, foreign_key: true
      t.references :team_group        , index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
