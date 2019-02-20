class League < TeamGroup
  has_many :schedules, -> { order(:week, :number) },
                       foreign_key: 'team_group_id', dependent: :destroy

  before_save :set_abbr

  def won_lost_tied_for(team)
    games_finished.find_all { |g|
      g.for?(team)
    }.each_with_object([0] * 3) { |game, results|
      index = %w[W L T].index(game.result_and_scores_for(team).first)
      results[index] += 1
    }
  end

  def standings
    teams.map { |team| TeamStanding.new(team) }.sort
  end

  def total_team_stats
    h_team_stats.values
  end

  def next_schedule
    return nil if schedules.empty?
    schedules.detect { |schedule| !schedule.game.final? }
  end

  def make_schedules
    return if teams.empty?
    team_ids = teams.map(&:id).sort_by { rand }
    raise "Not implemented yet for even number of Team's" if team_ids.size.even?
    team_ids.size.times do |week|
      (team_ids.size / 2).times do |i|
        h = Team.find(team_ids[i])
        v = Team.find(team_ids[-(i + 1)])
        game = Game.new(home_team: h, visitors: v)
        schedules.build(week: week + 1, number: i + 1, game: game)
        game = Game.new(home_team: v, visitors: h)
        schedules.build(week: week + 1 + team_ids.size, number: i + 1, game: game)
      end
      team_ids.unshift(team_ids.pop)
    end
  end

  def to_s
    "#{year} #{abbr}"
  end

  private

    def games_finished
      @games_finished ||= schedules.includes(:game).map(&:game).find_all(&:final?)
    end

    def h_team_stats
      @h_team_stats ||= make_h_team_stats
    end

    def make_h_team_stats
      h_init = teams.map { |team| [team.id, Stats::Team.new(team)] }.to_h
      games_finished.each_with_object(h_init) { |game, h|
        game_stats = Stats::Game.new(game)
        h[game.home_team.id].add(game_stats.stats_home    )
        h[game.visitors .id].add(game_stats.stats_visitors)
      }
    end

    def set_abbr
      return if abbr
      self.abbr = (name.split + [self.class.name]).map(&:first).join
    end
end
