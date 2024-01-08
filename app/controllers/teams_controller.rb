class TeamsController < ApplicationController

  def index
    league = League.find_by(id: params[:league_id])
    league = League.order(:updated_at).last unless league

    @shows_last_year = params[:shows_last_year] == 'true'

    new_teams = Team.where(team_group_id: nil).where.not(abbr: %w[H V])
    @teams = league.teams + new_teams
  end
end
