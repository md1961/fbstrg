class AddTeamGroupIdToTeam < ActiveRecord::Migration[5.1]

  def change
    add_reference :teams, :team_group, foreign_key: true
  end
end
