module GameAttributes

  def offense
    home_has_ball ? home_team : visitors
  end

  def defense
    home_has_ball ? visitors : home_team
  end

  def timeout_left(is_offense = true)
    is_home = (home_has_ball && is_offense) || (!home_has_ball && !is_offense)
    is_home ? timeout_home : timeout_visitors
  end

  def score_diff
    (score_home - score_visitors) * (home_has_ball ? 1 : -1)
  end

  def final_FG_stands?
    -3 <= score_diff && score_diff <= 0
  end

  def goal_to_go?
    100 - ball_on <= yard_to_go
  end

  def drive_started_from
    return nil if kickoff? || kickoff_after_safety?

    next_play = nil
    plays.order(number: :desc).each do |play|
      break if play.possession_changed?
      next_play = play
    end

    next_play&.game_snapshot&.ball_on
  end
end
