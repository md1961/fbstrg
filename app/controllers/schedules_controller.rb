class SchedulesController < ApplicationController

  def postpone
    schedule = Schedule.find(params[:id])
    schedule.postpone

    redirect_to League.find(params[:league_id])
  end
end
