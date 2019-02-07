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
end

end
