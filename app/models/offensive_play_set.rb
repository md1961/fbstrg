class OffensivePlaySet < ActiveRecord::Base
  include PlaySetTool

  has_many :offensive_play_set_choices

  def choose(game)
    if game.down == 4
      choose_on_4th_down(game)
    else
      condition = \
        if game.ball_on >= 100 - 10
          'number <= 12'
        elsif game.ball_on >= 100 - 20
          'number <= 16'
        else
          ''
        end
      choices = offensive_play_set_choices.joins(:offensive_play).where(condition)
      pick_from(choices).offensive_play
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
