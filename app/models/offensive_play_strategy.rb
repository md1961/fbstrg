class OffensivePlayStrategy < ActiveRecord::Base
  include PlayStrategyTool

  has_many :offensive_play_strategy_choices

  def choose(game)
    if game.down == 4
      choose_on_4th_down(game)
    else
      pick_from(offensive_play_strategy_choices).offensive_play
    end
  end

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
