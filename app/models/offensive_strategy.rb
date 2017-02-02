class OffensiveStrategy < ActiveRecord::Base
  include StrategyTool

  attr_reader :play_set

  def offensive_play_set(game)
    if close_to_goal_line?(game)
      OffensivePlaySet.goal_line
    elsif offense_running_out_of_time?(game)
      OffensivePlaySet.aggresive
    elsif defense_running_out_of_time?(game)
      OffensivePlaySet.ball_control
    elsif need_long_yardage?(game)
      OffensivePlaySet.aim_long
    elsif need_very_short_yardage?(game)
      OffensivePlaySet.aim_short
    elsif half_ending?(game)
      OffensivePlaySet.hurry_up
    else
      OffensivePlaySet.standard
    end
  end

  def choose_play(game)
    @play_set = nil
    if game.kickoff?
      OffensivePlay.kickoff
    elsif game.extra_point?
      OffensivePlay.extra_point
    elsif kick_FG_now?(game)
      OffensivePlay.field_goal
    elsif game.down == 4
      choose_on_4th_down(game)
    else
      @play_set = offensive_play_set(game)
      @play_set.choose(game)
    end
  end

  private

    def choose_on_4th_down(game)
      ball_on = game.ball_on
      if ball_on <= 100 - 40
        OffensivePlay.punt
      elsif ball_on > 100 - 33
        OffensivePlay.field_goal
      else
        pct_for_FG = MathUtil.linear_interporation([40, 0], [33, 100], 100 - ball_on)
        rand(1 .. 100) > pct_for_FG ? OffensivePlay.punt : OffensivePlay.field_goal
      end
    end

    TIME_LEFT_TO_KICK_FG_NOW = 15

    def kick_FG_now?(game)
      return false if [1, 3].include?(game.quarter) || game.ball_on < 50
      game.time_left <= TIME_LEFT_TO_KICK_FG_NOW && (game.quarter == 2 || game.final_FG_stands?)
    end
end
