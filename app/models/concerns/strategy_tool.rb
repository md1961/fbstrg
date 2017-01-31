module StrategyTool

  def offense_running_out_of_time?(game)
    game.score_diff < 0 && time_running_out?(game)
  end

  def defense_running_out_of_time?(game)
    game.score_diff > 0 && time_running_out?(game)
  end

  def time_running_out?(game)
    game.time_left / (game.score_diff.abs.to_f / 7) < 5 * 60
  end
end
