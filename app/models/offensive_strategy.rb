class OffensiveStrategy < ActiveRecord::Base

  def offensive_play_set
    @offensive_play_set ||= OffensivePlaySet.find_by(name: 'Standard')
  end

  def choose_play(game)
    if game.kickoff?
      OffensivePlay.kickoff
    elsif game.extra_point?
      OffensivePlay.extra_point
    elsif game.down == 4
      choose_on_4th_down(game)
    else
      offensive_play_set.choose(game)
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
end
