module GamesHelper

  def down_and_yard_display(game)
    if game.end_of_half?
      'END OF HALF'
    elsif game.end_of_game?
      'END OF GAME'
    elsif game.kickoff?
      'KICKOFF'
    elsif game.extra_point?
      'XP'
    else
      yard = game.goal_to_go? ? 'Goal' : game.yard_to_go
      "#{game.down.ordinalize} & #{yard}"
    end
  end

  def time_left_display(time_left)
    m = time_left / 60
    format("%02d:%02d", m, time_left - m * 60)
  end

  def ball_on_display(game)
    ball_on = game.ball_on
    if game.end_of_half? || game.end_of_game?
      nil
    elsif ball_on == 50
      '--- 50'
    elsif ball_on < 50
      "Own #{format('%2d', ball_on)}"
    else
      "Opp #{format('%2d', 100 - ball_on)}"
    end
  end

  def offensive_play_display(game)
    play_set = game.offensive_play_set
    "#{game.offensive_play}#{play_set.blank? ? '' : " : from #{play_set}"}"
  end

  def defensive_play_display(game)
    play_set = game.defensive_play_set
    "#{game.defensive_play}#{play_set.blank? ? '' : " : from #{play_set}"}"
  end
end
