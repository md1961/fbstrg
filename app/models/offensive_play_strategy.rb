class OffensivePlayStrategy < ActiveRecord::Base
  include PlayStrategyTool

  has_many :offensive_play_strategy_weights

  def choose
    pick_from(offensive_play_strategy_weights).offensive_play
  end
end
