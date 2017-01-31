class OffensiveStrategy < ActiveRecord::Base

  # TODO: Move to somewhere else to be used from DefensiveStrategy as well.
  def running_out_of_time?(game)
    score_diff = game.score_diff
    score_diff < 0 && game.time_left / (score_diff.abs.to_f / 7) < 5 * 60
  end

  def offensive_play_set(game)
    if running_out_of_time?(game)
      OffensivePlaySet.aggresive
    else
      OffensivePlaySet.standard
    end
  end

  def choose_play(game)
    if game.kickoff?
      OffensivePlay.kickoff
    elsif game.extra_point?
      OffensivePlay.extra_point
    elsif kick_FG_now?(game)
      OffensivePlay.field_goal
    elsif game.down == 4
      choose_on_4th_down(game)
    else
      play_set = offensive_play_set(game)
      play_set.choose(game)
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
