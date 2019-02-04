class DefensiveStrategy < ApplicationRecord
  include StrategyTool

  attr_reader :play_set

  def defensive_play_set(game)
    if cannot_down_in_field?(game)
      DefensivePlaySet.pass_only
    elsif close_to_goal_line?(game)
      DefensivePlaySet.goal_line
    elsif defense_running_out_of_time?(game)
      DefensivePlaySet.expect_run
    elsif offense_running_out_of_time?(game)
      DefensivePlaySet.prevent
    elsif needs_long_yardage?(game)
      DefensivePlaySet.stop_long
    elsif needs_very_short_yardage?(game)
      DefensivePlaySet.stop_short
    elsif plays_safe_back_on_goal_line?(game)
      DefensivePlaySet.back_on_goal
    elsif threatening_into_end_zone?(game)
      DefensivePlaySet.goal_stand
    elsif needs_to_hurry_before_halftime?(game)
      DefensivePlaySet.slow_down
    else
      DefensivePlaySet.standard
    end
  end

  def choose_play(game)
    @play_set = defensive_play_set(game)
    @play_set.choose
  end
end
