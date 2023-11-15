module PlayoffScheduleMaker
  module_function

  def build_next_schedule_for(league)
    unless league.is_a?(League)
      raise "Arguemnt must be a League (#{league.class} given)"
    end

    playoff_berths = league.playoff_berths

    return [] if playoff_berths.size.odd?

    schedules = []
    case playoff_berths.size
    when 2  # Super Bowl
      teams = playoff_berths.map(&:team)
      teams << teams.shift if rand(2).zero?
      game = Game.new(home_team: teams.first, visitors: teams.last, is_neutral: true)
      schedules << league.schedules.build(week: league.next_week, number: 1, game: game, is_playoff: true)
    when 4, 6
      number = 1
      playoff_berths_by_conference_of(league).each do |conference, playoff_berths|
        teams = playoff_berths.sort.map(&:team)
        teams.shift if teams.size == 3
        game = Game.new(home_team: teams.first, visitors: teams.last)
        schedules << league.schedules.build(week: league.next_week, number: number, game: game, is_playoff: true)
        number += 1
      end
    else
      raise NotImplementedError, "playoff_berths.size == #{playoff_berths.size}"
    end

    schedules
  end

    def playoff_berths_by_conference_of(league)
      league.playoff_berths.group_by { |playoff_berth|
        playoff_berth.team.conference
      }.then { |h|
        a = h.to_a
        a << a.shift if rand(2).zero?
        a.to_h
      }
    end
end
