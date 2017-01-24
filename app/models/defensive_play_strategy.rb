class DefensivePlayStrategy < ActiveRecord::Base
  include PlayStrategyTool

  has_many :defensive_play_strategy_choices

  def choose
    pick_from(defensive_play_strategy_choices).defensive_play
  end
end
