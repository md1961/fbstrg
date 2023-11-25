module LeaguesHelper

  def team_result_display_for(team)
    team.team_record.to_s
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
