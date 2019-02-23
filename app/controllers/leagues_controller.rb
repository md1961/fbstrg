class LeaguesController < ApplicationController

  def index
    redirect_to League.order(:updated_at).last
  end

  def show
    @league = League.find(params[:id])
    @schedules_by_week = @league.schedules.includes(:game).group_by(&:week)
    games = @schedules_by_week.values.flatten.map(&:game)
    @game_played_last = games.sort_by(&:updated_at).last
  end
end
