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
    mins = time_left / 60
    format("%d:%02d", mins, time_left - mins * 60)
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
    return 'X' * 10 if game.defense_human? && game.playing?
    play_set = game.offensive_play_set
    "#{game.offensive_play}#{play_set.blank? ? '' : " : from #{play_set}"}"
  end

  def defensive_play_display(game)
    play_set = game.defensive_play_set
    "#{game.defensive_play}#{play_set.blank? ? '' : " : from #{play_set}"}"
  end

  def yards_per_carry_display(stats)
    "%2.1fy" % stats.run_stats.yards_per_carry
  end

  def pct_comp_display(stats)
    "%3.1f%%" % stats.pass_stats.pct_comp
  end

  def long_runs_display(stats)
    "[#{stats.run_stats.longs.sort.reverse.join(' ')}]"
  end

  def long_passes_display(stats)
    "[#{stats.pass_stats.longs.sort.reverse.join(' ')}]"
  end
end
