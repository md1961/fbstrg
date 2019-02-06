module StrategyTool

  MINUTES_NEEDED_FOR_TOUCHDOWN = 5
  LONG_YARDAGE_PER_DOWN = 6
  VERY_SHORT_YARDAGE = 2
  MINUTES_ENDING_HALF = 4

  SECONDS_TO_MOVE_5_YARDS = 40.0 / 8 * 5

  NOTABLE_METHODS = %i[
    needs_offense_timeout?
    needs_no_huddle?
    needs_defense_timeout?
  ]

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
      (game.score_diff <=  0 && game.time_left <= seconds_needed_for_field_goal(game)) ||
      (game.score_diff <=  0 && game.time_left <= 120 && zone_aggresive?(game))
    )
  end

  def needs_to_hurry_before_halftime?(game)
    game.quarter == 2 && (
      game.time_left <= 120 && threatening_into_end_zone?(game) ||
      game.time_left <= seconds_needed_for_touchdown(game) && (
        (zone_aggresive?(game)) ||
        (game.score_diff <= 7 && !zone_conservative?(game))
      )
    )
  end

  def cannot_down_in_field?(game)
    game.timeout_left == 0 && game.time_left <= 20 && (
      (game.quarter == 4 && game.score_diff.between?(-3, 0) && game.ball_on >= 50) ||
      (game.quarter == 2 && game.ball_on >= 40)
    )
  end

  def plays_safe_back_on_goal_line?(game)
    game.ball_on <= 15 && !time_running_out?(game)
  end

  def threatening_into_end_zone?(game)
    game.ball_on >= 80
  end

  def close_to_goal_line?(game)
    game.ball_on >= 97
  end

  def needs_long_yardage?(game)
    game.yard_to_go.to_f / (4 - game.down) >= LONG_YARDAGE_PER_DOWN
  end

  def needs_very_short_yardage?(game)
    game.down == 3 && game.yard_to_go <= VERY_SHORT_YARDAGE
  end

  def tries_fourth_down_gamble?(game)
    return false unless game.down == 4
    return false if game.quarter == 4 && game.score_diff > 0
    game.quarter == 4 && (
      (game.score_diff < -3 &&
       game.time_left <= seconds_needed_for_touchdown(game) + seconds_needed_to_get_ball_back(game)) ||
      (game.score_diff < -7 && !zone_conservative?(game)
       game.time_left <= (seconds_needed_for_touchdown(game) + seconds_needed_to_get_ball_back(game)) * 2)
    ) ||
    (
      (game.ball_on <= (100 - 35) - rand(5) && game.yard_to_go <= 3)
    )
  end

  def kick_FG_now?(game)
    return false if [1, 3].include?(game.quarter) || game.ball_on < 50
    (game.quarter == 2 || game.final_FG_stands?) && (
      (game.time_left <= 15 && game.timeout_left <= 0) ||
      (game.time_left <= 10 * game.timeout_left)
    )
  end

  def needs_offense_timeout?(game)
    return false if game.clock_stopped || game.timeout_left <= 0
    return false if [1, 3].include?(game.quarter) || game.time_left >= 60 * 2
    return false if game.score_diff > 0
    return false if game.time_left >= 40 && game.down == 4 && !tries_fourth_down_gamble?(game)
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
    return false if game.time_left >= 40 && game.down == 4 && !tries_fourth_down_gamble?(game)
    time_running_out?(game) || needs_to_hurry_before_halftime?(game)
  end

  def needs_defense_timeout?(game)
    return false if game.clock_stopped || game.timeout_left(false) <= 0
    return false if [1, 3].include?(game.quarter) || game.time_left >= 60 * 3
    game.quarter == 4 && game.score_diff >= 0 && (
      # TODO: Adjust conditions depending on scores.
      true
    ) ||
    game.quarter == 2 && (
      (game.down == 4 && !tries_fourth_down_gamble?(game))
    )
  end

  def kneel_down_to_finish_game?(game)
    game.ball_on > 2 &&
      game.time_left <= 40 * (4 - game.down + (game.clock_stopped? ? 1 : 0)) - 39 * game.timeout_left(false)
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

    def seconds_needed_to_get_ball_back(game)
      50 * 4 - 35 * game.timeout_left
    end
end
