module LeaguesHelper

  def game_result_display(game, team)
    return [] unless game&.end_of_game? && game&.for?(team)
    score_own, score_opp = game.score_home, game.score_visitors
    score_own, score_opp = score_opp, score_own if team == game.visitors
    r = %w[L T W][(score_own <=> score_opp) + 1]
    [r, "#{score_own} - #{score_opp}"]
  end
end
