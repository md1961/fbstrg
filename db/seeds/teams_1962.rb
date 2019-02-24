year = 1962

leagues = League.where("year = ?", year)
unless leagues.size == 1
  STDERR.puts "Number of leagues for #{year} is #{leagues.size}"
  exit
end
league = leagues.first

teams_existing = league.teams
{
  MIA: 5,
  NYJ: 3,
  CHI: 0,
  GB:  4,
  BAL: 2,
}.each do |abbr, qb_read|
  team = teams_existing.find_by(abbr: abbr.to_s)
  raise "Cannot find Team with abbr of '#{abbr}'" unless team
  team.team_trait.update!(qb_read: qb_read)
end


%w[KC CIN NYG].each do |abbr|
  team = league.teams.find_by(abbr: abbr)
  team.destroy if team
end

result_chart = PlayResultChart.first
offensive_strategy = OffensiveStrategy.first
defensive_strategy = DefensiveStrategy.first

league.teams \
  << Team.create!(
    name:               'Kansas City',
    abbr:               'KC',
    play_result_chart:  result_chart,
    offensive_strategy: offensive_strategy,
    defensive_strategy: defensive_strategy,
  ).tap { |team|
    team.create_team_trait!(
      run_yardage:       2,
      run_breakaway:     3,
      pass_short:        5,
      pass_long:         1,
      pass_breakaway:    1,
      pass_protect:      0,
      qb_mobility:       4,
      qb_read:           5,

      run_defense:       4,
      run_tackling:      5,
      pass_rush:         4,
      pass_coverage:     4,
      pass_tackling:     3,

      place_kicking:     4,
      return_breakaway:  5,
      return_coverage:   5,
    )
  } \
  << Team.create!(
    name:               'Cincinnati',
    abbr:               'CIN',
    play_result_chart:  result_chart,
    offensive_strategy: offensive_strategy,
    defensive_strategy: defensive_strategy,
  ).tap { |team|
    team.create_team_trait!(
      run_yardage:       0,
      run_breakaway:     0,
      pass_short:        4,
      pass_long:         5,
      pass_breakaway:    4,
      pass_protect:      3,
      qb_mobility:       3,
      qb_read:           3,

      run_defense:      -2,
      run_tackling:     -1,
      pass_rush:        -1,
      pass_coverage:    -2,
      pass_tackling:    -1,

      place_kicking:     1,
      return_breakaway:  1,
      return_coverage:   1,
    )
  } \
  << Team.create!(
    name:               'N.Y. Giants',
    abbr:               'NYG',
    play_result_chart:  result_chart,
    offensive_strategy: offensive_strategy,
    defensive_strategy: defensive_strategy,
  ).tap { |team|
    team.create_team_trait!(
      run_yardage:       2,
      run_breakaway:     3,
      pass_short:        3,
      pass_long:         1,
      pass_breakaway:   -1,
      pass_protect:      1,
      qb_mobility:       1,
      qb_read:           1,

      run_defense:       5,
      run_tackling:      3,
      pass_rush:         5,
      pass_coverage:     3,
      pass_tackling:     2,

      place_kicking:     0,
      return_breakaway:  3,
      return_coverage:   3,
    )
  }
