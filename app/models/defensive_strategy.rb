class DefensiveStrategy < ActiveRecord::Base
  include StrategyTool

  attr_reader :play_set

  def defensive_play_set(game)
    if defense_running_out_of_time?(game)
      DefensivePlaySet.expect_run
    elsif offense_running_out_of_time?(game)
      DefensivePlaySet.prevent
    elsif need_long_yardage?(game)
      DefensivePlaySet.stop_long
    elsif need_very_short_yardage?(game)
      DefensivePlaySet.stop_short
    else
      DefensivePlaySet.standard
    end
  end

  def choose_play(game)
    @play_set = defensive_play_set(game)
    @play_set.choose
  end
end
