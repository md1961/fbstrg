class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update]

  def index
    redirect_to game_path(1)
  end

  def show
  end

  def update
    @game.play(params[:play])
    @game.save!
    render :show
  end

  private

    def set_game
      @game = Game.find(params[:id])
    end
end
