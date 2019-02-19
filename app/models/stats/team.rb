module Stats

class Team
  attr_reader :team, :pass_stats, :run_stats

  def initialize(team)
    @team = team
    @pass_stats = Stats::Pass.new(team)
    @run_stats  = Stats::Run.new(team)
  end

  def tally_from(play)
    @pass_stats.tally_from(play)
    @run_stats .tally_from(play)
  end

  def add(other)
    raise "Teams don't match ('#{team.abbr}' vs '#{other.team.abbr}')" unless team == other.team
    @pass_stats.add(other.pass_stats)
    @run_stats.add(other.run_stats)
  end
end

end
