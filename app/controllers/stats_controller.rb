class StatsController < ApplicationController

  def index
    game = Game.find_by(id: params[:game_id]) || Game.first
    @stats = Stats::Game.new(game)
  end
end
