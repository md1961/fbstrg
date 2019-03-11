class TeamGroup < ApplicationRecord
  has_many :direct_teams, class_name: 'Team'
  has_many :child_groups, class_name: 'TeamGroup', foreign_key: 'parent_id'
  belongs_to :parent    , class_name: 'TeamGroup', foreign_key: 'parent_id', optional: true

  before_save :set_abbr

  def teams
    return direct_teams unless direct_teams.empty?
    child_groups.flat_map(&:teams)
  end

  def make_round_robin_schedules
    return if teams.empty?
    team_ids = teams.map(&:id).sort_by { rand }
    team_surplus = team_ids.size.odd? ? nil : Team.find(team_ids.pop)
    team_ids.size.times.each_with_object([]) { |week, schedules|
      (team_ids.size / 2 + 1).times do |i|
        h = Team.find(team_ids[i])
        v = Team.find(team_ids[-(i + 1)])
        if h == v
          if !team_surplus
            next
          else
            v = team_surplus
          end
        end
        h, v = v, h if week.even?
        game = Game.new(home_team: h, visitors: v)
        schedules << Schedule.new(week: week + 1, number: i + 1, game: game)
        game = Game.new(home_team: v, visitors: h)
        schedules << Schedule.new(week: week + 1 + team_ids.size, number: i + 1, game: game)
      end
      team_ids.unshift(team_ids.pop)
    }
  end

  private

    def set_abbr
      return if abbr
      self.abbr = (name.split + [self.class.name]).map(&:first).join
    end
end
