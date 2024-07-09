class DefensivePlaySetsController < ApplicationController

  def update
    defensive_play_set = DefensivePlaySet.find(params[:id])
    defensive_play_set.update_weights(params[:choice])

    redirect_to play_sets_path
  end
end
