class LeaguesController < ApplicationController

  def index
    redirect_to League.order(:updated_at).last
  end

  def show
    @league = League.find(params[:id])
    @schedules_by_week = @league.schedules.includes(:game).group_by(&:week)
    @game_played_last = @league.games_finished.sort_by(&:updated_at).last
    @shows_stats = params[:shows_stats] == 'true'

    session[:pretty_display] = params[:pretty] == 'true' if params[:pretty]
  end
end
