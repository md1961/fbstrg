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

  def schedule_index_display(schedule, week)
    return week unless schedule
    content_tag :span do
      concat schedule.week
      concat content_tag :span, "-#{schedule.number}", class: 'number'
    end
  end

  def fgs_made_att_display(range, kick_stats)
    "#{kick_stats.fgs_made_from(range)}-#{kick_stats.attempts_from(range)}"
  end

  def link_to_toggle_stats
    label, params = @shows_stats ? ['Hide Stats', {}] \
                                 : ['Show Stats', {shows_stats: true}]
    link_to label, league_path(@league, params)
  end

  def schedule_with_team_result(schedule)
    return nil unless schedule
    game = schedule.game
    optional_strs = {}
    optional_strs['h'] = " (#{team_result_display_for(game.home_team)})"
    optional_strs['v'] = " (#{team_result_display_for(game.visitors )})"
    schedule.to_s(optional_strs)
  end
end
