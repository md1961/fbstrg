module Stats

class Team
  attr_reader :team, :pass_stats, :run_stats, :kick_stats, :pass_defense_stats, :run_defense_stats,
              :kickoff_return_stats, :punt_return_stats, :int_return_stats

  def initialize(team)
    @team = team
    @pass_stats = Stats::Pass.new(team)
    @run_stats  = Stats::Run.new(team)
    @kick_stats = Stats::Kick.new(team)
    @pass_defense_stats = Stats::Pass.new(team)
    @run_defense_stats  = Stats::Run.new(team)
    @kickoff_return_stats = Stats::KickoffReturn.new(team)
    @punt_return_stats    = Stats::PuntReturn.new(team)
    @int_return_stats     = Stats::IntReturn.new(team)
  end

  def tally_offense_from(play)
    @pass_stats.tally_from(play)
    @run_stats .tally_from(play)
    @kick_stats.tally_from(play)
  end

  def tally_return_from(play)
    @kickoff_return_stats.tally_from(play)
    @punt_return_stats   .tally_from(play)
    @int_return_stats    .tally_from(play)
  end

  def set_defense_stats(opponent_stats)
    @pass_defense_stats = opponent_stats.pass_stats
    @run_defense_stats  = opponent_stats.run_stats
  end

  def add(other)
    raise "Teams don't match ('#{team.abbr}' vs '#{other.team.abbr}')" unless team == other.team
    @pass_stats.add(other.pass_stats)
    @run_stats .add(other.run_stats)
    @kick_stats.add(other.kick_stats)
    @pass_defense_stats.add(other.pass_defense_stats)
    @run_defense_stats .add(other.run_defense_stats)
    @kickoff_return_stats.add(other.kickoff_return_stats)
    @punt_return_stats   .add(other.punt_return_stats)
    @int_return_stats    .add(other.int_return_stats)
  end
end

end
