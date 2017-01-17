class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update]

  def index
    if Game.count <= 1
      Game.create! if Game.count == 0
      redirect_to game_path(Game.first)
    else
      @games = Game.all
    end
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
