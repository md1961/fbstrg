class PlaySetsController < ApplicationController

  def index
    @offensive_play_sets = OffensivePlaySet.all.includes(:offensive_play_set_choices)
    @offensive_plays = OffensivePlay.normal_plays
    @defensive_play_sets = DefensivePlaySet.all.includes(:defensive_play_set_choices)
    @defensive_plays = DefensivePlay.all
  end
end
