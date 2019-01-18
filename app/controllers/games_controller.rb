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
    offensive_play_id = session[:offensive_play_id]
    @game.offensive_play = OffensivePlay.find(offensive_play_id) if offensive_play_id
  end

  def update
    @game_snapshot_prev = nil
    if tampering_game?(params[:play])
      @game.tamper(params[:play])
    elsif @game.end_of_game?
      # No action.
    elsif @game.end_of_quarter? || @game.end_of_half?
      if session[:next_quarter]
        @game.advance_to_next_quarter
        @game.save!
        session[:next_quarter] = nil
      else
        session[:next_quarter] = true
      end
    elsif @game.huddle?
      session[:offensive_play_id] = @game.determine_offensive_play(params[:play])&.id
    else
      @game.offensive_play = OffensivePlay.find(session[:offensive_play_id])
      @game.play(params[:play])
      if @game.error_message.blank?
        session[:offensive_play_id] = nil
        @game.save!
      end
      @game_snapshot_prev = @game.game_snapshots.order(:play_id).last
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

    RE_TAMPER_GAME = /\A\s*{\s*(:?\w+:\s+[+-]?\d+\s*,?\s*)+\s*}\s*\z/

    def tampering_game?(value)
      value =~ RE_TAMPER_GAME
    end
end
