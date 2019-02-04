class OffensiveStrategy < ApplicationRecord
  include StrategyTool

  attr_reader :play_set

  def offensive_play_set(game)
    if cannot_down_in_field?(game)
      OffensivePlaySet.pass_only
    elsif close_to_goal_line?(game)
      OffensivePlaySet.goal_line
    elsif offense_running_out_of_time?(game)
      OffensivePlaySet.aggresive
    elsif defense_running_out_of_time?(game)
      OffensivePlaySet.ball_control
    elsif need_long_yardage?(game)
      OffensivePlaySet.aim_long
    elsif need_very_short_yardage?(game)
      OffensivePlaySet.aim_short
    elsif need_to_hurry_before_halftime?(game)
      OffensivePlaySet.hurry_up
    else
      OffensivePlaySet.standard
    end
  end

  def choose_play(game)
    @play_set = nil
    if game.kickoff?
      OffensivePlay.normal_kickoff
    elsif game.extra_point?
      OffensivePlay.extra_point
    elsif needs_offense_timeout?(game)
      [nil, 'TO']
    elsif needs_no_huddle?(game)
      [nil, 'NH']
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
        OffensivePlay.normal_punt
      elsif ball_on > 100 - 33
        OffensivePlay.field_goal
      else
        pct_for_FG = MathUtil.linear_interporation([40, 0], [33, 100], 100 - ball_on)
        rand(1 .. 100) > pct_for_FG ? OffensivePlay.normal_punt : OffensivePlay.field_goal
      end
    end
end
