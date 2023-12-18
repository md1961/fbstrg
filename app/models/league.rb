class League < TeamGroup
  has_many :schedules, -> { order(:week, :number) },
                       foreign_key: 'team_group_id', dependent: :destroy
  has_many :playoff_berths, foreign_key: 'team_group_id', dependent: :destroy
  has_many :playoff_traits, foreign_key: 'team_group_id', dependent: :destroy

  def self.create_next
    last_league = League.order(:year).last
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

  def divisions
    conferences.flat_map(&:divisions)
  end

  def games_finished
    @games_finished ||= schedules.includes(:game).where(is_playoff: false).map(&:game).find_all(&:final?)
  end

  def game_ongoing
    schedules.includes(:game).map(&:game).sort_by(&:updated_at).last.then { |game|
      game&.ongoing? ? game : nil
    }
  end

  def total_team_stats
    h_team_stats.values
  end

  def next_schedule
    schedules.detect { |schedule| !schedule.game.final? }.tap do |schedule|

      return nil if conferences.empty?

      if schedules.size > 0 && schedule.nil?
        if playoff_berths.empty?
          berths = PlayoffBerth.build_initial_berths(self)
          PlayoffBerth.transaction do
            berths.map(&:save!)
          end
        else
          confirm_playoff_loser_elimination
        end

        playoff_schedules = PlayoffScheduleMaker.build_next_schedule_for(self)
        unless playoff_schedules.empty?
          Schedule.transaction do
            playoff_schedules.map(&:save!)
          end

          return next_schedule
        end
      end

    end
  end

  def postpone_next_schedule
    return unless next_schedule

    next_schedule.postpone
  end

  def next_week
    schedules.includes(:game).find_all { |schedule| schedule.game.final? }.pluck(:week).max + 1
  end

  def playoff_name_in(week)
    playoff_traits.find_by(week: week)&.name
  end

  def eliminate_loser_in!(game)
    return if !game.playoff? || !game.final?

    loser = game.loser
    playoff_berth = playoff_berths.find_by(team: loser)

    playoff_berth&.destroy
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

    def confirm_playoff_loser_elimination
      schedules.where(is_playoff: true).map(&:game).each do |game|
        eliminate_loser_in!(game)
      end
    end
end
