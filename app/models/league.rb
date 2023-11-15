class League < TeamGroup
  has_many :schedules, -> { order(:week, :number) },
                       foreign_key: 'team_group_id', dependent: :destroy
  has_many :playoff_berths, foreign_key: 'team_group_id', dependent: :destroy

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

  def league
    self
  end

  def conferences
    child_groups
  end

  def games_finished
    @games_finished ||= schedules.includes(:game).map(&:game).find_all(&:final?)
  end

  def game_ongoing
    schedules.includes(:game).map(&:game).sort_by(&:updated_at).last.then { |game|
      game.final? ? nil : game
    }
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
