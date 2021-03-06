class OffensiveStrategy < ApplicationRecord
  include StrategyTool

  attr_reader :play_set

  def hurrying?(game)
    offense_running_out_of_time?(game)
  end

  def offensive_play_set(game)
    if cannot_down_in_field?(game)
      OffensivePlaySet.pass_only
    elsif close_to_goal_line?(game)
      OffensivePlaySet.goal_line
    elsif offense_running_out_of_time?(game)
      OffensivePlaySet.hurry_up
    elsif defense_running_out_of_time?(game)
      OffensivePlaySet.ball_control
    elsif needs_long_yardage?(game)
      OffensivePlaySet.aim_long
    elsif needs_very_short_yardage?(game)
      OffensivePlaySet.aim_short
    elsif plays_safe_back_on_goal_line?(game)
      OffensivePlaySet.back_on_goal
    elsif needs_to_hurry_before_halftime?(game)
      OffensivePlaySet.hurry_up
    else
      OffensivePlaySet.standard
    end
  end

  def choose_play(game)
    @play_set = nil
    if game.kickoff?
      needs_onside_kickoff?(game) ? OffensivePlay.onside_kickoff : OffensivePlay.normal_kickoff
    elsif game.extra_point?
      OffensivePlay.extra_point
    elsif game.kickoff_after_safety?
      OffensivePlay.kickoff_after_safety
    elsif needs_defense_timeout?(game)
      [nil, 'TD']
    elsif let_clock_run_to_finish_quarter?(game)
      OffensivePlay.let_clock_run
    elsif kneel_down_to_finish_game?(game) || kneel_down_to_finish_half?(game)
      OffensivePlay.kneel_down
    elsif needs_offense_timeout?(game) && !game.goes_into_huddle
      [nil, 'TO']
    elsif needs_no_huddle?(game) && !game.goes_into_huddle
      [nil, 'NH']
    elsif kick_FG_now?(game)
      OffensivePlay.field_goal
    elsif tries_hail_mary?(game)
      OffensivePlay.hail_mary
    elsif game.down == 4 && !tries_fourth_down_gamble?(game)
      choose_on_4th_down(game)
    else
      @play_set = offensive_play_set(game)
      @play_set.choose(game)
    end
  end

  private

    def choose_on_4th_down(game)
      ball_on = game.ball_on
      if ball_on < 100 - 45 || (game.quarter == 1 && game.score_diff >=  0 && ball_on < 100 - 40) \
                            || (game.quarter >= 3 && game.score_diff >  14 && ball_on < 100 - 40)
        OffensivePlay.normal_punt
      elsif ball_on > 100 - 35
        OffensivePlay.field_goal
      else
        pct_for_FG = MathUtil.linear_interporation([45, 5], [35, 100], 100 - ball_on)
        rand(1 .. 100) > pct_for_FG ? OffensivePlay.normal_punt : OffensivePlay.field_goal
      end
    end
end
