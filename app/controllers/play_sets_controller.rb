class PlaySetsController < ApplicationController

  def index
    @play_sets = OffensivePlaySet.all.includes(:offensive_play_set_choices)
    @offensive_plays = OffensivePlay.normal_plays
  end
end
