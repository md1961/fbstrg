class TeamRecord
  include Comparable

  attr_reader :team, :conference
  delegate :won, :lost, :tied, :pf, :pa, :games, :pct, to: :@league
  attr_accessor :rank, :remarks

  def initialize(team)
    @team = team
    @league     = Record.new
    @conference = Record.new
    @rank = 1
    @remarks = []
  end

  def conference_pct
    @team.conference.team_record_for(@team).conference.pct
  end

  def update_by(game)
    @league    .update_by(game, @team)
    @conference.update_by(game, @team) if game.within_conference?
  end

  def remark_display
    remarks.empty? ? '' : "(by #{remarks.join(', ')})"
  end

  def <=>(other)
    rank <=> other.rank
  end

  def to_s
    @league.to_s
  end

  class Record
    attr_reader :won, :lost, :tied, :pf, :pa

    def initialize
      @won  = 0
      @lost = 0
      @tied = 0
      @pf   = 0
      @pa   = 0
    end

    def games
      won + lost + tied
    end

    def pct
      -(won + tied * 0.5)
    end

    def update_by(game, team)
      result, score_own, score_opp = game.result_and_scores_for(team)
      return unless result
      case result.upcase
      when 'W'
        @won += 1
      when 'L'
        @lost += 1
      else
        @tied += 1
      end
      @pf += score_own
      @pa += score_opp
    end

    def to_s
      ss = [won, lost]
      ss << tied if tied > 0
      ss.join('-')
    end
  end
end
