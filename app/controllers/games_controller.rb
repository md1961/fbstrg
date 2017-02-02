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
    session[:body_class] = params[:real] ? 'real' : nil
  end

  def update
    if @game.end_of_half? || @game.end_of_game?
      if session[:next_quarter]
        @game.to_3rd_quarter
        @game.save!
        session[:next_quarter] = nil
      else
        session[:next_quarter] = true
      end
    elsif session[:offensive_play_id].blank?
      session[:offensive_play_id] = @game.choose_offensive_play.id
    elsif
      @game.offensive_play = OffensivePlay.find(session[:offensive_play_id])
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
      begin
        @game = Game.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to games_path
      end
    end
end
