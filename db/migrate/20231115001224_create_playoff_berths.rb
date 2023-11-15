class CreatePlayoffBerths < ActiveRecord::Migration[5.2]

  def change
    create_table :playoff_berths do |t|
      t.references :team_group, null: false, foreign_key: true
      t.references :team      , null: false, foreign_key: true
      t.integer    :rank      , null: false

      t.timestamps
    end

    add_index :playoff_berths, %i[team_group_id team_id], unique: true
  end
end
