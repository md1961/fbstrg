module StrategyTool

  MINUTES_NEEDED_FOR_TOUCHDOWN = 5
  LONG_YARDAGE_PER_DOWN = 6
  VERY_SHORT_YARDAGE = 2
  MINUTES_ENDING_HALF = 4

  SECONDS_TO_MOVE_5_YARDS = 40.0 / 8 * 5

  def offense_running_out_of_time?(game)
    game.score_diff < 0 && time_running_out?(game)
  end

  def defense_running_out_of_time?(game)
    game.score_diff > 0 && time_running_out?(game)
  end

  # TODO: Add conditions for possible-tie or sudden-death in overtime.
  def time_running_out?(game)
    game.quarter == 4 && (
      (game.score_diff <= -3 && game.time_left <= seconds_needed_for_touchdown(game)) ||
      (game.score_diff <=  0 && game.time_left <= seconds_needed_for_field_goal(game))
    )
  end

  def need_to_hurry_before_halftime?(game)
    game.quarter == 2 && game.time_left <= seconds_needed_for_touchdown(game) && (
      (zone_aggresive?(game)) ||
      (game.score_diff <= 7 && !zone_conservative?(game))
    )
  end

  def half_ending?(game)
    game.quarter == 2 && game.time_left <= MINUTES_ENDING_HALF * 60
  end

  def threatening_into_end_zone?(game)
    game.ball_on >= 80
  end

  def close_to_goal_line?(game)
    game.ball_on >= 97
  end

  def need_long_yardage?(game)
    game.yard_to_go.to_f / (4 - game.down) >= LONG_YARDAGE_PER_DOWN
  end

  def need_very_short_yardage?(game)
    game.down == 3 && game.yard_to_go <= VERY_SHORT_YARDAGE
  end

  def needs_offense_timeout?(game)
    return false if [1, 3].include?(game.quarter) || game.time_left >= 60 * 2
    return false if game.clock_stopped || game.timeout_left <= 0
    if game.time_left >= 40 * 2
      return game.timeout_left >= 3
    elsif game.time_left >= 40 * 1
      return game.timeout_left >= 2
    end
    return true if game.timeout_left >= 2
    game.time_left <= 15 && game.timeout_left >= 1
  end

  def needs_no_huddle?(game)
    return false if game.clock_stopped || game.no_huddle
    time_running_out?(game) || need_to_hurry_before_halftime?(game)
  end

    def zone_conservative?(game)
      game.ball_on <= 20 + rand(-3 .. 3)
    end

    def zone_aggresive?(game)
      game.ball_on >= 40 + rand(-5 .. 0)
    end

    def seconds_needed_for_touchdown(game)
      (100 - game.ball_on) / 5.0 * SECONDS_TO_MOVE_5_YARDS
    end

    YARD_LINE_TO_REACH_FOR_FIELD_GOAL = 25

    def seconds_needed_for_field_goal(game)
      (100 - YARD_LINE_TO_REACH_FOR_FIELD_GOAL - game.ball_on) / 5.0 * SECONDS_TO_MOVE_5_YARDS
    end
end
