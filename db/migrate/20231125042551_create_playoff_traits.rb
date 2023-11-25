class CreatePlayoffTraits < ActiveRecord::Migration[5.2]

  def change
    create_table :playoff_traits do |t|
      t.references :team_group, null: false, foreign_key: true
      t.integer    :week      , null: false
      t.string     :name      , null: false

      t.timestamps
    end
  end
end
