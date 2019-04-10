class HeadToHeadGroup
  attr_reader :teams

  def initialize(teams)
    leagues = teams.map(&:league)
    raise "Illegal argument teams of different league" unless leagues.uniq.size == 1
    @teams = teams
    @league = leagues.first
  end

  def team_record_for(team)
    @league.games_finished.find_all { |g|
      g.head_to_head_for?(@teams)
    }.each_with_object(TeamRecord.new(team)) { |game, record|
      record.update_by(game)
    }
  end
end
