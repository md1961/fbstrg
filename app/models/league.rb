class League < TeamGroup
  has_many :schedules, -> { order(:week, :number) },
                       foreign_key: 'team_group_id', dependent: :destroy

  def next_schedule
    return nil if schedules.empty?
    schedules.detect { |schedule| !schedule.game.end_of_game? }
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
    "#{year} #{name} #{self.class}"
  end
end
