module StrategyTool

  MINUTES_NEEDED_FOR_TOUCHDOWN = 5
  LONG_YARDAGE_PER_DOWN = 6

  def offense_running_out_of_time?(game)
    game.score_diff < 0 && time_running_out?(game)
  end

  def defense_running_out_of_time?(game)
    game.score_diff > 0 && time_running_out?(game)
  end

  def time_running_out?(game)
    game.quarter >= 4 && \
      game.time_left / (game.score_diff.abs.to_f / 7) < MINUTES_NEEDED_FOR_TOUCHDOWN * 60
  end

  def need_long_yardage?(game)
    game.yard_to_go.to_f / (4 - game.down) >= LONG_YARDAGE_PER_DOWN
  end
end
