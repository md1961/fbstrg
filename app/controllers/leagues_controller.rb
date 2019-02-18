class LeaguesController < ApplicationController

  def index
    redirect_to League.first
  end

  def show
    @league = League.find(params[:id])
    @schedules_by_week = @league.schedules.group_by(&:week)
  end
end
