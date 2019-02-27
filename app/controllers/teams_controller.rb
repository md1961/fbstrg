class TeamsController < ApplicationController

  def index
    league = League.find_by(id: params[:league_id])
    teams = league&.teams || Team.all
    @teams = teams.where.not(abbr: %w[H V])
  end
end
