class DefensivePlayStrategy < ActiveRecord::Base
  include PlayStrategyTool

  has_many :defensive_play_strategy_weights

  def choose
    pick_from(defensive_play_strategy_weights).defensive_play
  end
end
