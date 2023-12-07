class FourByFourScheduleMaker

  def initialize(league)
    unless league.conferences.then { |cs|
      [cs.size, cs.flat_map(&:divisions).size]
    } == [2, 4]
      raise "'#{league}' does not have 2 conferences and 4 divisions"
    end

    @league = league
  end

  class Matching
    include Comparable

    attr_reader :team_mark_away, :team_mark_home

    def initialize(str)
      @team_mark_away, @team_mark_home = str.split('@').map { |s| TeamMark.new(s) }
    end

    def game(league, conference: nil, division: nil, division_names: [])
      visitors, home_team = \
        if division_names.empty?
          [team_mark_away, team_mark_home].map { |team_mark|
            league.teams.detect { |team|
              team.abbr == team_mark.team_abbr(conference: conference, division: division)
            }
          }
        else
          [team_mark_away, team_mark_home].zip(division_names).map { |team_mark, division_name|
            league.teams.detect { |team|
              team.abbr == team_mark.team_abbr(division_name: division_name, league: league)
            }
          }
        end
      Game.new(visitors: visitors, home_team: home_team)
    end

    def <=>(other)
      ordering <=> other.ordering
    end

    def to_s
      [team_mark_away, team_mark_home].join(' at ')
    end

    protected

      def ordering
        -[@team_mark_away, @team_mark_home].map(&:rank).min
      end

    class TeamMark
      attr_reader :of, :rank

      def initialize(s)
        unless s =~ /\A([ANEW]?)([1-5])\z/
          raise "Illegal TeamMark string '#{s}'"
        end

        @of, @rank = of_lookup($1), Integer($2)
      end

      def team_abbr(conference: nil, division: nil, division_name: nil, league: nil)
        if conference && division
          raise "Both Conference and Division must not be specified"
        elsif %i[East West].include?(of) && conference.nil?
          raise "Conference must be specified for '#{self}'"
        elsif %i[AFC NFC].include?(of) && (league.nil? || division_name.nil?)
          raise "Both league and division_name must be specified for '#{self}'"
        end

        if conference
          division = conference.divisions.find_by(name: of)
        elsif division_name
          division = league.conferences.find_by(abbr: of).divisions.find_by(name: division_name)
        end

        team_abbr_of(division, rank)
      end

      def to_s
        [of, rank].compact.join(' #')
      end

      private

        def of_lookup(c)
          {A: :AFC, N: :NFC, E: :East, W: :West}[c.to_sym]
        end

        def team_abbr_of(division, rank)
          {
            'AFC East' => %w[spacer MIA BAL NYJ HOU],
            'AFC West' => %w[spacer KC PIT CIN OAK],
            'NFC East' => %w[spacer NYG DAL WAS ATL],
            'NFC West' => %w[spacer CHI GB NO SF]
          }[division.to_s][rank]
        end
    end
  end

  def make_schedules
    formats = [
      "Division    1@4 2@3",
      "Division    1@3 2@4",
      "Division    1@2 3@4",
      "Division    4@1 3@2",
      "Division    3@1 4@2",
      "Division    2@1 4@3",
      "Conference  W4@E1 W3@E2 W2@E3 W1@E4",
      "Conference  E1@W3 E2@W4 E3@W1 E4@W2",
      "Conference  W2@E1 W1@E2 W3@E4 W4@E3",
      "Conference  E1@W1 E2@W2 E3@W3 E4@W4",
      "InterSameD  A1@N3 A2@N4 A3@N1 A4@N2",
      "InterSameD  N2@A1 N1@A2 N3@A4 N4@A3",
      "InterSameD  A1@N1 A2@N2 A3@N3 A4@N4",
      "InterCross  N1@A3 N2@A4 N3@A1 N4@A2",
      "InterCross  A2@N1 A1@N2 A3@N4 A4@N3",
      "InterCross  N1@A1 N2@A2 N3@A3 N4@A4",
    ]

    games_by_week = {}

    formats.each.with_index(1) do |format, week|
      kind, *str_matchings = format.split
      matchings = str_matchings.map { |str| Matching.new(str) }.sort
      games_by_week[week] = []

      case kind
      when 'Division'
        matchings.each do |matching|
          @league.divisions.sort_by { rand }.each do |division|
            games_by_week[week] << matching.game(@league, division: division)
          end
        end
      when 'Conference'
        matchings.each do |matching|
          @league.conferences.sort_by { rand }.each do |conference|
            games_by_week[week] << matching.game(@league, conference: conference)
          end
        end
      when /\AInter(.+)\z/
        array_of_division_names = \
          case $1
          when 'SameD'
            [%w[East East], %w[West West]]
          when 'Cross'
            [%w[East West], %w[West East]]
          else
           raise "Illegal format: '#{format}'"
          end

        matchings.each do |matching|
          array_of_division_names.sort_by { rand }.each do |division_names|
            games_by_week[week] << matching.game(@league, division_names: division_names)
          end
        end
      else
        raise "Illegal format: '#{format}'"
      end
    end

    games_by_week.each do |week, games|
      puts "Week #{week}"
      games.each do |game|
        puts "  #{game}"
      end
    end

    nil
  end
end
