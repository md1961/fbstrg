class MiscsController < ApplicationController

  def index
    min, max = -10, 10
    @freq_dists = [
      FreqDist.new(9, 21, 100) { MathUtil.pick_from_decreasing_distribution(10, 20) },
      # FreqDist.new(min, max, 100) { 6.times.map { rand(-1 .. 1) }.sum },
      # FreqDist.new(min, max, 100) { 3.times.map { rand(-2 .. 2) }.sum },
      # FreqDist.new(min, max, 100) { 2.times.map { rand(-3 .. 3) }.sum },
    ]

    game_params = GameParams.new(session[:game_params])
    game_params.update(params[:yard])
    @game = Game.new(game_params.to_h)
    session[:game_params] = game_params.to_h

    redirect_to miscs_path if params[:yard].present?
  end

  class GameParams

    def initialize(params = nil)
      @params = params&.symbolize_keys || {
        home_has_ball: true,
        ball_on: 20,
        down: 1,
        yard_to_go: 10,
      }
    end

    def update(yard)
      return if yard.blank?

      @params[:ball_on] += yard.to_i
      @params[:down] += 1
      @params[:yard_to_go] -= yard.to_i
      if @params[:yard_to_go] <= 0
        @params[:down] = 1
        @params[:yard_to_go] = 10
      elsif @params[:down] > 4 && @params[:yard_to_go] > 0
        @params[:home_has_ball] = !@params[:home_has_ball]
        @params[:ball_on] = 100 - @params[:ball_on]
        @params[:down] = 1
        @params[:yard_to_go] = 10
      end
    end

    def to_h
      @params
    end
  end

  class FreqDist
    attr_reader :min, :max

    def initialize(min, max, n, &f)
      @min = min
      @max = max
      @n = n
      @f = f
    end

    def h_freq
      @n.times.each_with_object(Hash.new(0)) { |_, h| h[@f.call] += 1 }
    end
  end
end
