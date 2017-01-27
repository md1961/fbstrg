class OffensivePlayStrategy < ActiveRecord::Base
  include PlayStrategyTool

  has_many :offensive_play_strategy_choices

  def choose
    pick_from(offensive_play_strategy_choices).offensive_play
  end

  def choose_on_4th_down(game)
    ball_on = game.ball_on
    if ball_on <= 100 - 40
      Play.punt
    elsif ball_on > 100 - 33
      Play.field_goal
    else
      rand(1 .. 100) > MathUtil.linear_interporation([40, 0], [33, 100], 100 - ball_on) ? Play.punt : Play.field_goal
    end
  end
end
