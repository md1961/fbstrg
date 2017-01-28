class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update]

  def index
    if Game.count <= 1
      Game.create!(home_team: Team.first, visitors: Team.second) if Game.count == 0
      redirect_to Game.first
    else
      @games = Game.all
    end
  end

  def show
  end

  def update
    if @game.needs_choice? && session[:offensive_play_id].blank?
      session[:offensive_play_id] = @game.choose_offensive_play.id
    else
      if @game.needs_choice?
        @game.offensive_play = OffensivePlay.find(session[:offensive_play_id])
      end
      session[:offensive_play_id] = nil
      @game.play(params[:play])
      @game.save! unless @game.error_message
    end
    render :show
  end

  def new
    redirect_to Game.create!
  end

  private

    def set_game
      @game = Game.find(params[:id])
    end
end
