class DefensivePlaySetsController < ApplicationController

  def update
    defensive_play_set = DefensivePlaySet.find(params[:id])
    DefensivePlaySet.transaction do
      defensive_play_set.update!(params.require(:defensive_play_set).permit(:name))
      defensive_play_set.update_weights(params[:choice])
    end

    redirect_to play_sets_path
  end
end
