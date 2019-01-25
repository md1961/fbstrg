class OffDefChartsController < ApplicationController

  DEFAULT_TYPE = 'result'
  TYPES = [DEFAULT_TYPE, 'int']

  def index
    @type = params[:type]
    redirect_to off_def_charts_path(type: DEFAULT_TYPE) if @type.blank?
    offensive_play_scope, @f_item = \
      case @type
      when 'int'
        [
          :pass_plays,
          ->(offensive_play, defensive_play) {
            "%5.1f" % Play.pct_intercept_base(offensive_play, defensive_play)
          }
        ]
      else
        [
          :normal_plays,
          ->(offensive_play, defensive_play) {
            PlayResultChart.first.result(offensive_play, defensive_play)
          }
        ]
      end
    @offensive_plays = OffensivePlay.send(offensive_play_scope)
    @defensive_plays = DefensivePlay.all
  end
end
