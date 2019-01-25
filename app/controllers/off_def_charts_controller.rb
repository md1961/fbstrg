class OffDefChartsController < ApplicationController

  def index
    @f_item = ->(offensive_play, defensive_play) {
      "%5.1f" % Play.pct_intercept_base(offensive_play, defensive_play)
    }
    @offensive_plays = OffensivePlay.pass_plays
    @defensive_plays = DefensivePlay.all
  end
end
