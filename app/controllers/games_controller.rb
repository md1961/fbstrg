class GamesController < ApplicationController

  def index
    redirect_to game_path(1)
  end

  def show
    @game = Game.find(params[:id])
  end
end
