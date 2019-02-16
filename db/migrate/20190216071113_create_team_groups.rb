class CreateTeamGroups < ActiveRecord::Migration[5.1]

  def change
    create_table :team_groups do |t|
      t.string  :type     , null: false
      t.string  :name     , null: false
      t.string  :abbr
      t.integer :year     , null: false
      t.integer :parent_id

      t.timestamps
    end
  end
end
