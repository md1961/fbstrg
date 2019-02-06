module Stats

class Team
  attr_reader :pass_stats

  def initialize(team)
    @team = team
    @pass_stats = Stats::Pass.new(team)
  end

  def tally_from(play)
    @pass_stats.tally_from(play)
  end
end

end
