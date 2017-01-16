module GamesHelper

  def time_left_display(time_left)
    m = time_left / 60
    format("%02d:%02d", m, time_left - m * 60)
  end

  def ball_on_display(game)
    is_on_home = game.is_ball_to_home
    ball_on = game.ball_on
    is_on_home = !is_on_home if ball_on > 50
    team = is_on_home ? 'H' : 'V'
    team = '' if ball_on == 50
    "#{team} #{ball_on > 50 ? 100 - ball_on : ball_on}"
  end
end
