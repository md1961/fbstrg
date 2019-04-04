class TeamStanding
  include Comparable

  attr_reader :team, :conference
  delegate :won, :lost, :tied, :pf, :pa, to: :@league

  def initialize(team)
    @team = team
    @league     = Record.new(team.won_lost_tied_pf_pa)
    @conference = Record.new(team.won_lost_tied_pf_pa(within: :conference))
  end

  def games
    won + lost + tied
  end

  def pct
    -(won + tied * 0.5)
  end

  def <=>(other)
    pct <=> other.pct
  end

  class Record
    attr_reader :won, :lost, :tied, :pf, :pa

    def initialize(args)
      @won, @lost, @tied, @pf, @pa = args
    end

    def to_s
      [won, lost, tied].join('-')
    end
  end
end
