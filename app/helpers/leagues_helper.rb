module LeaguesHelper

  def game_result_display(game, team)
    rs = game&.result_and_scores_for(team)
    return [] if !rs || rs.empty?
    [rs[0], "#{rs[1]} - #{rs[2]}"]
  end
end
