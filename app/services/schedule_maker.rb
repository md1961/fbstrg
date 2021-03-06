module ScheduleMaker
  module_function

  def clear_schedules!(league)
    raise "Cannot clear schedules of a league already started." if league.games_finished.size > 0
    schedules = league.schedules
    games = Game.where(id: schedules.map(&:game_id))
    ApplicationRecord.transaction do
      schedules.destroy_all
      games.destroy_all
    end
  end

  def make_round_robin_schedules(teams)
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

  def make_6_team_x_2_conference_schedules(league)
    kinds = %i[
      conf  inter conf  inter conf  conf  inter conf
      inter conf  inter conf  conf  inter conf  conf
    ]

    conf_number = 1
    h_conf_week_converter = kinds.each.with_index(1).each_with_object({}) { |(kind, week), h|
      next if kind == :inter
      h[conf_number] = week
      conf_number += 1
    }

    conf1, conf2 = league.conferences
    conf1, conf2 = conf2, conf1 if rand(2).zero?
    schedules_conf1, schedules_conf2 = [conf1, conf2].map { |conf|
      make_round_robin_schedules(conf.teams).tap { |schedules|
        schedules.group_by(&:week).each do |week, schedules_by_week|
          schedules_by_week.each_with_index do |schedule, offset|
            schedule.week = h_conf_week_converter[week]
            offset0 = (conf == conf1 && week.odd?) || (conf == conf2 && week.even?) ? 0 : 1
            schedule.number += offset0 + offset
          end
        end
      }
    }

    team_ids1, team_ids2 = [conf1, conf2].map { |conf| conf.teams.map(&:id).sort_by { rand } }
    conf1_at_home = rand(2).zero?
    schedules_inter = kinds.each.with_index(1).each_with_object([]) { |(kind, week), schedules|
      next if kind == :conf
      team_ids1.zip(team_ids2).each.with_index(1) do |(team_id1, team_id2), number|
        h = Team.find(team_id1)
        v = Team.find(team_id2)
        h, v = v, h unless conf1_at_home
        game = Game.new(home_team: h, visitors: v)
        schedules << Schedule.new(week: week, number: number, game: game)
      end
      team_ids1.rotate!
      team_ids2.rotate!(2)
      conf1_at_home = !conf1_at_home
    }

    (schedules_conf1 + schedules_conf2 + schedules_inter).tap { |schedules|
      check_6_team_x_2_conference_schedules(schedules, league)
    }
  end

  def check_6_team_x_2_conference_schedules(schedules, league)
    size = 12 * 16 / 2
    raise "Size must be #{size} (#{schedules.size})" unless schedules.size == size

    league.teams.each do |team|
      team_schedules = schedules.find_all { |s| s.for?(team) }
      weeks = team_schedules.map(&:week).sort
      raise "Weeks of schedules for #{team} is illegally #{weeks.join(', ')}" unless weeks == (1 .. 16).to_a

      home_schedules = team_schedules.find_all { |s| s.game.home_team == team }
      raise "Number of home schedules for #{team} must be 8 (#{home_schedules.size})" unless home_schedules.size == 8

      conference = team.conference
      conf_schedules = team_schedules.find_all { |s| conference.teams.include?(s.game.opponent_for(team)) }
      raise "Number of conf. schedules for #{team} must be 10 (#{conf_schedules.size})" unless conf_schedules.size == 10

      conf_home_schedules = conf_schedules.find_all { |s| s.game.home_team == team }
      raise "Number of conf. home schedules for #{team} must be 5 (#{conf_home_schedules.size})" unless conf_home_schedules.size == 5

      conf_teams = conference.teams - [team]

      conf_home_opponents = conf_home_schedules.map { |s| s.game.opponent_for(team) }
      raise "Conf. home schedule for #{team} is illegally #{conf_home_opponents.join(', ')}" \
          unless conf_home_opponents.size == conf_teams.size && (conf_home_opponents - conf_teams).empty?

      conf_away_schedules = conf_schedules - conf_home_schedules
      conf_away_opponents = conf_away_schedules.map { |s| s.game.opponent_for(team) }
      raise "Conf. away schedule for #{team} is illegally #{conf_away_opponents.join(', ')}" \
          unless conf_away_opponents.size == conf_teams.size && (conf_away_opponents - conf_teams).empty?

      inter_schedules = team_schedules - conf_schedules
      inter_opponents = inter_schedules.map { |s| s.game.opponent_for(team) }
      inter_teams = (league.conferences - [conference]).first.teams
      raise "Inter conf. schedule for #{team} is illegally #{inter_opponents.join(', ')}" \
          unless inter_opponents.size == inter_teams.size && (inter_opponents - inter_teams).empty?

      inter_home_schedules = inter_schedules.find_all { |s| s.game.home_team == team }
      raise "Number of inter. home schedules for #{team} must be 3 (#{inter_home_schedules.size})" unless inter_home_schedules.size == 3
    end

    schedules.group_by(&:week).each do |week, schedules_by_week|
      raise "Number of schedules for week #{week} must be 6 (#{schedules_by_week.size})" unless schedules_by_week.size == 6

      numbers = schedules_by_week.map(&:number).sort
      raise "'number's of schedules for week #{week} is illegally #{numbers.join(', ')}" unless numbers == (1 .. 6).to_a
    end
  end
end
