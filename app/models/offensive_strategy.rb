class OffensiveStrategy < ApplicationRecord
  attr_reader :play_set

  def hurrying?(game)
    set_strategy_tool(game)

    @strategy_tool.offense_running_out_of_time?
  end

  def offensive_play_set(game)
    set_strategy_tool(game)

    if @strategy_tool.cannot_down_in_field?
      OffensivePlaySet.pass_only
    elsif @strategy_tool.close_to_goal_line?
      OffensivePlaySet.goal_line
    elsif @strategy_tool.offense_running_out_of_time?
      OffensivePlaySet.hurry_up
    elsif @strategy_tool.defense_running_out_of_time?
      OffensivePlaySet.ball_control
    elsif @strategy_tool.needs_long_yardage?
      OffensivePlaySet.aim_long
    elsif @strategy_tool.needs_very_short_yardage?
      OffensivePlaySet.aim_short
    elsif @strategy_tool.plays_safe_back_on_goal_line?
      OffensivePlaySet.back_on_goal
    elsif @strategy_tool.needs_to_hurry_before_halftime?
      OffensivePlaySet.hurry_up
    else
      OffensivePlaySet.standard
    end
  end

  def choose_play(game)
    set_strategy_tool(game)

    @play_set = nil
    if game.kickoff?
      @strategy_tool.needs_onside_kickoff? ? OffensivePlay.onside_kickoff : OffensivePlay.normal_kickoff
    elsif game.extra_point?
      @strategy_tool.tries_two_point_conversion? ? OffensivePlay.two_point_conversion : OffensivePlay.extra_point
    elsif game.kickoff_after_safety?
      OffensivePlay.kickoff_after_safety
    elsif @strategy_tool.needs_defense_timeout?
      [nil, 'TD']
    elsif @strategy_tool.let_clock_run_to_finish_quarter?
      OffensivePlay.let_clock_run
    elsif @strategy_tool.kneel_down_to_finish_game? || @strategy_tool.kneel_down_to_finish_half?
      OffensivePlay.kneel_down
    elsif @strategy_tool.needs_offense_timeout? && !game.goes_into_huddle
      [nil, 'TO']
    elsif @strategy_tool.needs_no_huddle? && !game.goes_into_huddle
      [nil, 'NH']
    elsif @strategy_tool.kick_FG_now?
      if !game.clock_stopped && game.timeout_left(true) > 0 && @strategy_tool.use_up_time_and_take_timeout?
        return [nil, 'TO-0']
      end
      OffensivePlay.field_goal
    elsif @strategy_tool.tries_hail_mary?
      OffensivePlay.hail_mary
    elsif game.down == 4 && !@strategy_tool.tries_fourth_down_gamble?
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

    def set_strategy_tool(game)
      @strategy_tool = StrategyTool.new(game)
    end
end
