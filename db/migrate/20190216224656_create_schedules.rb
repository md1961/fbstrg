class CreateSchedules < ActiveRecord::Migration[5.1]

  def change
    create_table :schedules do |t|
      t.references :team_group, foreign_key: true
      t.integer    :week      , null: false
      t.integer    :number    , null: false
      t.references :game      , foreign_key: true

      t.timestamps
    end
  end
end
