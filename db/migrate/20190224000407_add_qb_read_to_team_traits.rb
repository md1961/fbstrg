class AddQbReadToTeamTraits < ActiveRecord::Migration[5.1]

  def change
    add_column :team_traits, :qb_read, :integer, null: false, default: 0
  end
end
