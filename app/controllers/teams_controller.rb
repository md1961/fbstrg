class TeamsController < ApplicationController

  def index
    league = League.find_by(id: params[:league_id])
    new_teams = Team.where(team_group_id: nil).where.not(abbr: %w[H V])
    league = League.order(:updated_at).last unless league
    @teams = league.teams + new_teams
    @team_trait_id = params[:team_trait_id].to_i
  end
end
