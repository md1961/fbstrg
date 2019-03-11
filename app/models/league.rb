class League < TeamGroup
  has_many :schedules, -> { order(:week, :number) },
                       foreign_key: 'team_group_id', dependent: :destroy

  def self.create_next
    last_league = League.order(:updated_at).last
    ApplicationRecord.transaction do
      create!(
        name: last_league.name,
        year: last_league.year + 1,
        direct_teams: last_league.teams.map { |team|
          team.dup.tap { |new_team|
            new_team.update!(team_trait: team.team_trait.dup)
          }
        }
      )
    end
  end

  def prev_league
    self.class.find_by(year: year - 1)
  end

  def next_league
    self.class.find_by(year: year + 1)
  end

  def won_lost_tied_pf_pa_for(team)
    games_finished.find_all { |g|
      g.for?(team)
    }.each_with_object([0] * 5) { |game, results|
      result, score_own, score_opp = game.result_and_scores_for(team)
      index = %w[W L T].index(result)
      results[index] += 1
      results[3] += score_own
      results[4] += score_opp
    }
  end

  def games_finished
    @games_finished ||= schedules.includes(:game).map(&:game).find_all(&:final?)
  end

  def standings
    teams.map { |team| TeamStanding.new(team) }.sort
  end

  def total_team_stats
    h_team_stats.values
  end

  def next_schedule
    schedules.detect { |schedule| !schedule.game.final? }
  end

  def to_s
    "#{year} #{abbr}"
  end

  private

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
end
