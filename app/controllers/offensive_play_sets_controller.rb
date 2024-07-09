class OffensivePlaySetsController < ApplicationController

  def update
    offensive_play_set = OffensivePlaySet.find(params[:id])
    OffensivePlaySet.transaction do
      offensive_play_set.update!(params.require(:offensive_play_set).permit(:name))
      offensive_play_set.update_weights(params[:choice])
    end

    redirect_to play_sets_path
  end
end
