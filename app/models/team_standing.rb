class TeamStanding
  include Comparable

  attr_reader :team, :won, :lost, :tied, :pf, :pa

  def initialize(team)
    @team = team
    @won, @lost, @tied, @pf, @pa = team.won_lost_tied_pf_pa
  end

  def games
    won + lost + tied
  end

  def pct
    -(@won + @tied * 0.5)
  end

  def <=>(other)
    pct <=> other.pct
  end
end
