module LeaguesHelper

  def team_result_display_for(team)
    results = team.won_lost_tied_pf_pa.first(3)
    results.pop if results.last.zero?
    results.join('-')
  end

  def game_result_display(game, team)
    rs = game&.result_and_scores_for(team)
    return [] if !rs || rs.empty?
    [rs[0], "#{rs[1]} - #{rs[2]}"]
  end
end
