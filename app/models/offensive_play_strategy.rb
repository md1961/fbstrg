class OffensivePlayStrategy < ActiveRecord::Base
  include PlayStrategyTool

  has_many :offensive_play_strategy_choices

  def choose
    pick_from(offensive_play_strategy_choices).offensive_play
  end
end
