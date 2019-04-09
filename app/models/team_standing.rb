class TeamStanding

  def initialize(team_group)
    @team_group = team_group
    @team_records = team_group.teams.map { |team|
      team_group.team_record_for(team)
    }.sort
  end

  def teams
    @team_records.map(&:team)
  end

  def each(&block)
    @team_records.each(&block)
  end
end
