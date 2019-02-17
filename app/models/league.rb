class League < TeamGroup
  has_many :schedules, foreign_key: 'team_group_id', dependent: :destroy

  def make_schedules
    team_ids = teams.map(&:id).sort_by { rand }
    raise "Not implemented yet for even number of Team's" if team_ids.size.even?
    (team_ids.size - 1).times do |week|
      (team_ids.size / 2).times do |i|
        h = Team.find(team_ids[i])
        v = Team.find(team_ids[-(i + 1)])
        game = Game.new(home_team: h, visitors: v)
        schedules.build(week: week + 1, number: i + 1, game: game)
      end
      team_ids.unshift(team_ids.pop)
    end
  end
end