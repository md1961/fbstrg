class DefensiveStrategy < ApplicationRecord
  attr_reader :play_set

  def defensive_play_set(game)
    set_strategy_tool(game)

    if @strategy_tool.cannot_down_in_field?
      DefensivePlaySet.pass_only
    elsif @strategy_tool.close_to_goal_line?
      DefensivePlaySet.goal_line
    elsif @strategy_tool.defense_running_out_of_time?
      DefensivePlaySet.expect_run
    elsif @strategy_tool.offense_running_out_of_time?
      DefensivePlaySet.prevent
    elsif @strategy_tool.needs_long_yardage?
      DefensivePlaySet.stop_long
    elsif @strategy_tool.needs_very_short_yardage?
      DefensivePlaySet.stop_short
    elsif @strategy_tool.plays_safe_back_on_goal_line?
      DefensivePlaySet.back_on_goal
    elsif @strategy_tool.threatening_into_end_zone?
      DefensivePlaySet.goal_stand
    elsif @strategy_tool.needs_to_hurry_before_halftime?
      DefensivePlaySet.slow_down
    else
      DefensivePlaySet.standard
    end
  end

  def choose_play(game)
    @play_set = defensive_play_set(game)
    @play_set.choose
  end

  private

    def set_strategy_tool(game)
      @strategy_tool = StrategyTool.new(game)
    end
end
