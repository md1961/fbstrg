class OffDefChartsController < ApplicationController

  def index
    @type = params[:type]
    @f_item = ->(offensive_play, defensive_play) {
      case @type
      when 'int'
        "%5.1f" % Play.pct_intercept_base(offensive_play, defensive_play)
      else
        PlayResultChart.first.result(offensive_play, defensive_play)
      end
    }
    @offensive_plays = OffensivePlay.pass_plays
    @defensive_plays = DefensivePlay.all
  end
end
