class StrategyTool

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

  METHODS_TO_DELEGATE_TO_GAME =%i[
    quarter
    time_left
    clock_stopped
    ball_on
    down
    yard_to_go
    timeout_left
    score_diff
    kickoff?
    no_huddle
    final_FG_stands?
  ]

  def self.methods_for_judge
    public_instance_methods(false) - METHODS_TO_DELEGATE_TO_GAME
  end

  delegate *METHODS_TO_DELEGATE_TO_GAME, to: :@game

  def initialize(game)
    @game = game
  end

  def offense_running_out_of_time?
    (score_diff < 0 && time_running_out?) \
    || (score_diff == 0 && time_running_out? && zone_aggresive?)
  end

  def defense_running_out_of_time?
    score_diff > 0 && time_running_out?(for_defense: true)
  end

  def needs_onside_kickoff?
    return false unless kickoff?
    quarter == 4 && (
         (score_diff < -7 && time_left <= 3 * 60) \
      || (score_diff < -3 && time_left <= 2 * 60) \
      || (score_diff <  0 && time_left <= 2 * 60 - timeout_left * 10)
    )
  end

  def needs_to_hurry_before_halftime?
    quarter == 2 && (
      time_left <= seconds_needed_for_touchdown && (
           (zone_aggresive?) \
        || (score_diff <= 7 && !zone_conservative?)
      )
    )
  end

  def cannot_down_in_field?
    timeout_left == 0 && time_left <= 20 && (
         (quarter == 4 && score_diff.between?(-3, 0) && ball_on >= 50) \
      || (quarter == 2 && ball_on >= 40)
    )
  end

  def plays_safe_back_on_goal_line?
    ball_on <= 15 && !time_running_out?
  end

  def threatening_into_end_zone?
    ball_on >= 80
  end

  def close_to_goal_line?
    ball_on >= 97
  end

  def needs_long_yardage?
    yard_to_go.to_f / [(4 - down), 1].max >= LONG_YARDAGE_PER_DOWN
  end

  def needs_very_short_yardage?
    down == 3 && yard_to_go <= VERY_SHORT_YARDAGE
  end

  def tries_fourth_down_gamble?
    return false unless down == 4

    return true if quarter >= 5 && score_diff < 0

    return false if ball_on < 30 && yard_to_go >= 20 \
                    && !(quarter == 4 && time_left <= 120 && score_diff < 0)
    return false if ball_on < 30 && score_diff < -14
    return false if quarter == 4 && score_diff > 0
    return false if quarter == 4 && score_diff == 0 && zone_conservative?
    return false if quarter == 4 && score_diff <  0 && zone_conservative? && time_left >= 4 * 60
    return false if quarter == 4 && score_diff >= -14 && ball_on < 40 && time_left >= 10 * 60
    return false if quarter == 4 && score_diff >=  -7 && time_left >= 3 * 60 && yard_to_go > 15
    return false if quarter == 4 && time_left >= 5 * 60 && yard_to_go > 15
    return false if quarter == 4 && time_left >= 2 * 60 && yard_to_go >= 10 && !zone_aggresive? && timeout_left >= 3
    return false if quarter == 3 && score_diff > 14
    return false if quarter <= 3 && yard_to_go > 10
    return false if quarter == 2 && time_left <= seconds_needed_for_field_goal
    return false if quarter <= 2 && score_diff >= 0 && ball_on < 55 + rand(6)
    quarter == 4 && (
          (score_diff < 0 \
           && time_left <= seconds_needed_for_field_goal + seconds_needed_to_get_ball_back) \
       || (score_diff < -3 && ball_on > 50 \
           && time_left <= seconds_needed_for_touchdown + seconds_needed_to_get_ball_back) \
       || (score_diff < -7 && !zone_conservative? \
           && time_left <= (seconds_needed_for_touchdown + seconds_needed_to_get_ball_back) * 2) \
       || (score_diff < -14 && zone_aggresive?)
    ) \
    || (ball_on.between?(50, 100 - 35 - rand(5)) && yard_to_go <= 3) \
    || (quarter >= 3 && score_diff <= -14 && ball_on >= 50 && yard_to_go <= 10)
  end

  def tries_two_point_conversion?
    quarter >= 3 && [-15, -12, -11, -9, -8, -4, -1, 2, 6].include?(score_diff + 1)
  end

  # FIXME: Consider an alternative to FG try over 60 yard in final seconds.
  # TODO: Consider plays before trying FG.
  def kick_FG_now?
    return false if [1, 3].include?(quarter) || ball_on < 50
    return false if score_diff >= 0 && ball_on < 50 + 7 && time_left > 5
    (quarter == 2 || final_FG_stands?) && (
         (down == 4) \
      || (time_left <= 10) \
      || (time_left <= 15 && timeout_left <= 0)
    )
  end

  def use_up_time_and_take_timeout?
    return false if clock_stopped
    return false if time_left >= 60 * 2
    quarter == 2 || final_FG_stands?
  end

  def tries_hail_mary?
    (quarter == 4 && time_left < 10) && (
         (ball_on.between?(40, 60) && score_diff <  -3) \
      || (ball_on.between?(40, 50) && score_diff <= -3)
    ) \
      || (quarter == 2 && ball_on.between?(50, 75) && score_diff <= 14 && time_left < 10) \
      || (quarter == 2 && ball_on.between?(40, 75) && score_diff <   0 && time_left < 10)
  end

  def needs_offense_timeout?
    return false if clock_stopped || timeout_left <= 0
    return false if [1, 3].include?(quarter) || time_left >= 60 * 2
    return false if quarter == 4 && score_diff > 0
    return false if quarter == 2 && !zone_aggresive? && down >= 3
    return false if quarter == 2 && down >= 3 && yard_to_go >= 15 && time_left >= 60
    return false if time_left >= 40 && down == 4 && !tries_fourth_down_gamble?
    return false if time_left > seconds_needed_for_touchdown && [2, 4].include?(quarter)
    return false if time_left > seconds_needed_for_field_goal && quarter == 4 && score_diff >= -3
    if time_left >= 40 * 2
      return timeout_left >= 3
    elsif time_left >= 40 * 1
      return timeout_left >= 2
    end
    return true if timeout_left >= 2
    time_left <= 30 && timeout_left >= 1
  end

  def needs_no_huddle?
    return false if clock_stopped || no_huddle
    return false if time_left >= 40 && down == 4 && !tries_fourth_down_gamble?
    return false if final_FG_stands? && timeout_left > 0
    offense_running_out_of_time? || needs_to_hurry_before_halftime?
  end

  def needs_defense_timeout?
    return false if clock_stopped || timeout_left(false) <= 0
    return false if [1, 3].include?(quarter) || time_left >= 60 * 4
    quarter == 4 && (
         (score_diff > 8 && time_left <= 60 * 4) \
      || (score_diff > 0 && time_left <= 60 * 3)
    ) ||
    quarter == 2 && (
         (down == 4 && !tries_fourth_down_gamble?) \
      || (time_left <= 60 * 2 && ball_on <= 10 && down >= 2) \
      || (time_left <= 60 * 2 && ball_on <= 20 && down >= 3)
    )
  end

  def let_clock_run_to_finish_quarter?
    (time_left <= 40 && !clock_stopped && timeout_left(false).zero?) && (
         (quarter == 4 && score_diff > 0) \
      || (quarter == 2 && (
              (down == 4 && ball_on < 40) \
           || (zone_conservative?)
           )
         )
    )
  end

  def kneel_down_to_finish_game?
    can_finish = time_left < 35 * (5 - down - (clock_stopped ? 1 : 0)) - 34 * timeout_left(false)
    quarter == 4 && (
         (score_diff >  0 && ball_on >  2 && can_finish) \
      || (score_diff == 0 && ball_on < 40 && can_finish)
    )
  end

  def kneel_down_to_finish_half?
    quarter == 2 && ball_on > 2 \
      && time_left <= 30 * (5 - down - (clock_stopped ? 1 : 0) - timeout_left(false)) && (
           (ball_on < 10) \
        || (score_diff >= 0 && ball_on <= 20)
    )
  end

  private

    # TODO: Add conditions for possible-tie or sudden-death in overtime.
    def time_running_out?(for_defense: false)
      secs_for_TD = seconds_needed_for_touchdown
      secs_for_FG = seconds_needed_for_field_goal
      secs_for_stop = seconds_needed_to_get_ball_back

      score_diff = @game.score_diff
      time_left  = @game.time_left
      if for_defense
        score_diff *= -1
        time_left -= secs_for_stop
      end
      quarter == 4 && (
           (score_diff <=  -3 && time_left <= secs_for_TD) \
        || (score_diff <=   0 && time_left <= secs_for_FG) \
        || (score_diff <=   0 && time_left <= secs_for_TD && zone_aggresive?) \
        || (score_diff <=  -7 && time_left <= secs_for_TD + secs_for_FG + secs_for_FG) \
        || (score_diff <= -10 && time_left <= secs_for_TD * 2 + secs_for_FG) \
        || (score_diff <= -14)
      )
    end

    def zone_conservative?
      ball_on <= 20 + rand(-3 .. 3)
    end

    def zone_aggresive?
      ball_on >= 40 + rand(-5 .. 0)
    end

    def seconds_needed_for_touchdown
      (100 - ball_on) / 5.0 * SECONDS_TO_MOVE_5_YARDS
    end

    YARD_LINE_TO_REACH_FOR_FIELD_GOAL = 25

    def seconds_needed_for_field_goal
      (100 - YARD_LINE_TO_REACH_FOR_FIELD_GOAL - ball_on) / 5.0 * SECONDS_TO_MOVE_5_YARDS
    end

    def seconds_needed_to_get_ball_back
      50 * 4 - 35 * timeout_left
    end
end
