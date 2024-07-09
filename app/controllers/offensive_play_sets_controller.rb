class OffensivePlaySetsController < ApplicationController

  def update
    offensive_play_set = OffensivePlaySet.find(params[:id])
    offensive_play_set.update_weights(params[:choice])

    redirect_to play_sets_path
  end
end
