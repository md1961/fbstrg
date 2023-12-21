class LeaguesController < ApplicationController

  def index
    redirect_to League.order(:updated_at).last
  end

  def show
    @league = League.find(params[:id])

    @schedules_by_week = @league.schedules.includes(:game).regulars.group_by(&:week)
    @playoffs_by_week  = @league.schedules.includes(:game).playoffs.group_by(&:week)
    @game_played_last = @league.games_finished.sort_by(&:updated_at).last

    @displays_current_week = if params[:schedule_display]
                               params[:schedule_display] == 'current_week'
                             else
                               session[:displays_current_week]
                             end
    session[:displays_current_week] = @displays_current_week

    @shows_stats = params[:shows_stats] == 'true'
  end
end
