module GamesHelper

  def time_left_display(time_left)
    m = time_left / 60
    format("%02d:%02d", m, time_left - m * 60)
  end

  def ball_on_display(ball_on)
    if ball_on == 50
      '--- 50'
    elsif ball_on < 50
      "Own#{format('%2d', ball_on)}"
    else
      "Opp#{format('%2d', 100 - ball_on)}"
    end
  end
end
