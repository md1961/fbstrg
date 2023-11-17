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
    (game.score_diff < 0 && time_running_out?(game)) \
    || (game.score_diff == 0 && time_running_out?(game) && zone_aggresive?(game))
  end

  def defense_running_out_of_time?(game)
    game.score_diff > 0 && time_running_out?(game, for_defense: true)
  end

  # TODO: Add conditions for possible-tie or sudden-death in overtime.
  def time_running_out?(game, for_defense: false)
    score_diff, time_left = game.score_diff, game.time_left
    secs_for_TD = seconds_needed_for_touchdown(game)
    secs_for_FG = seconds_needed_for_field_goal(game)
    secs_for_stop = seconds_needed_to_get_ball_back(game)
    if for_defense
      score_diff *= -1
      time_left -= secs_for_stop
    end
    game.quarter == 4 && (
         (score_diff <=  -3 && time_left <= secs_for_TD) \
      || (score_diff <=   0 && time_left <= secs_for_FG) \
      || (score_diff <=   0 && time_left <= secs_for_TD && zone_aggresive?(game)) \
      || (score_diff <=  -7 && time_left <= secs_for_TD + secs_for_FG + secs_for_FG) \
      || (score_diff <= -10 && time_left <= secs_for_TD * 2 + secs_for_FG) \
      || (score_diff <= -14)
    )
  end

	def needs_onside_kickoff?(game)
		return false unless game.kickoff?
    game.quarter == 4 && (
         (game.score_diff < -7 && game.time_left <= 3 * 60) \
      || (game.score_diff < -3 && game.time_left <= 2 * 60) \
      || (game.score_diff <  0 && game.time_left <= 2 * 60 - game.timeout_left * 10)
		)
	end

  def needs_to_hurry_before_halftime?(game)
    game.quarter == 2 && (
      game.time_left <= seconds_needed_for_touchdown(game) && (
           (zone_aggresive?(game)) \
        || (game.score_diff <= 7 && !zone_conservative?(game))
      )
    )
  end

  def cannot_down_in_field?(game)
    game.timeout_left == 0 && game.time_left <= 20 && (
         (game.quarter == 4 && game.score_diff.between?(-3, 0) && game.ball_on >= 50) \
      || (game.quarter == 2 && game.ball_on >= 40)
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
    game.yard_to_go.to_f / [(4 - game.down), 1].max >= LONG_YARDAGE_PER_DOWN
  end

  def needs_very_short_yardage?(game)
    game.down == 3 && game.yard_to_go <= VERY_SHORT_YARDAGE
  end

  def tries_fourth_down_gamble?(game)
    return true if game.quarter >= 5 && game.score_diff < 0

    return false unless game.down == 4
    return false if game.ball_on < 30 && game.yard_to_go >= 20 \
                    && !(game.quarter == 4 && game.time_left <= 120 && game.score_diff < 0)
    return false if game.ball_on < 30 && game.score_diff < -14
    return false if game.quarter == 4 && game.score_diff > 0
    return false if game.quarter == 4 && game.score_diff == 0 && zone_conservative?(game)
    return false if game.quarter == 4 && game.score_diff <  0 && zone_conservative?(game) && game.time_left >= 4 * 60
    return false if game.quarter == 4 && game.score_diff >= -14 && game.ball_on < 40 && game.time_left >= 10 * 60
    return false if game.quarter == 4 && game.score_diff >=  -7 && game.time_left >= 3 * 60 && game.yard_to_go > 15
    return false if game.quarter == 4 && game.time_left >= 5 * 60 && game.yard_to_go > 15
    return false if game.quarter == 3 && game.score_diff > 14
    return false if game.quarter <= 3 && game.yard_to_go > 10
    return false if game.quarter == 2 && game.time_left <= seconds_needed_for_field_goal(game)
    return false if game.quarter <= 2 && game.score_diff >= 0 && game.ball_on < 55 + rand(6)
    game.quarter == 4 && (
          (game.score_diff < 0 \
           && game.time_left <= seconds_needed_for_field_goal(game) + seconds_needed_to_get_ball_back(game)) \
       || (game.score_diff < -3 && game.ball_on > 50 \
           && game.time_left <= seconds_needed_for_touchdown(game) + seconds_needed_to_get_ball_back(game)) \
       || (game.score_diff < -7 && !zone_conservative?(game) \
           && game.time_left <= (seconds_needed_for_touchdown(game) + seconds_needed_to_get_ball_back(game)) * 2)
    ) \
    || (game.ball_on.between?(50, 100 - 35 - rand(5)) && game.yard_to_go <= 3) \
    || (game.quarter >= 3 && game.score_diff <= -14 && game.ball_on >= 50 && game.yard_to_go <= 10)
  end

  def tries_two_point_conversion?(game)
    game.quarter >= 3 && [-15, -12, -11, -9, -8, -4, -1, 2, 6].include?(game.score_diff + 1)
  end

  # FIXME: Consider an alternative to FG try over 60 yard in final seconds.
  # TODO: Consider plays before trying FG.
  def kick_FG_now?(game)
    return false if [1, 3].include?(game.quarter) || game.ball_on < 50
    return false if game.score_diff.zero? && game.ball_on < 50 + 7 && game.time_left > 5
    (game.quarter == 2 || game.final_FG_stands?) && (
         (game.time_left <= 10) \
      || (game.time_left <= 15 && game.timeout_left <= 0)
    )
  end

  def tries_hail_mary?(game)
    (game.quarter == 4 && game.time_left < 10) && (
         (game.ball_on.between?(40, 60) && game.score_diff <  -3) \
      || (game.ball_on.between?(40, 50) && game.score_diff <= -3)
    ) \
      || (game.quarter == 2 && game.ball_on.between?(50, 75) && game.score_diff <= 14 && game.time_left < 10) \
      || (game.quarter == 2 && game.ball_on.between?(40, 75) && game.score_diff <   0 && game.time_left < 10)
  end

  def needs_offense_timeout?(game)
    return false if game.clock_stopped || game.timeout_left <= 0
    return false if [1, 3].include?(game.quarter) || game.time_left >= 60 * 2
    return false if game.quarter == 4 && game.score_diff > 0
    return false if game.quarter == 2 && !zone_aggresive?(game) && game.down >= 3
    return false if game.time_left >= 40 && game.down == 4 && !tries_fourth_down_gamble?(game)
    return false if game.time_left > seconds_needed_for_touchdown(game) && [2, 4].include?(game.quarter)
    return false if game.time_left > seconds_needed_for_field_goal(game) && game.quarter == 4 && game.score_diff >= -3
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
    offense_running_out_of_time?(game) || needs_to_hurry_before_halftime?(game)
  end

  def needs_defense_timeout?(game)
    return false if game.clock_stopped || game.timeout_left(false) <= 0
    return false if [1, 3].include?(game.quarter) || game.time_left >= 60 * 3
    game.quarter == 4 && game.score_diff > 0 && (
      # TODO: Adjust conditions depending on scores.
      true
    ) ||
    game.quarter == 2 && (
         (game.down == 4 && !tries_fourth_down_gamble?(game)) \
      || (game.time_left <= 60 * 2 && game.ball_on <= 10 && game.down >= 2) \
      || (game.time_left <= 60 * 2 && game.ball_on <= 20 && game.down >= 3)
    )
  end

  def let_clock_run_to_finish_quarter?(game)
    (game.time_left <= 40 && !game.clock_stopped && game.timeout_left(false).zero?) && (
         (game.quarter == 4 && game.score_diff > 0) \
      || (game.quarter == 2 && (
              (game.down == 4 && game.ball_on < 40) \
           || (zone_conservative?(game))
           )
         )
    )
  end

  def kneel_down_to_finish_game?(game)
    can_finish = game.time_left < 35 * (5 - game.down - (game.clock_stopped? ? 1 : 0)) - 34 * game.timeout_left(false)
    game.quarter == 4 && (
         (game.score_diff >  0 && game.ball_on >  2 && can_finish) \
      || (game.score_diff == 0 && game.ball_on < 40 && can_finish)
    )
  end

  def kneel_down_to_finish_half?(game)
    game.quarter == 2 && game.ball_on > 2 \
      && game.time_left <= 30 * (5 - game.down - (game.clock_stopped? ? 1 : 0) - game.timeout_left(false)) && (
           (game.ball_on < 20) \
        || (game.score_diff >= -14 && game.ball_on <= 30)
    )
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
