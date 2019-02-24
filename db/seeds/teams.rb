STDERR.puts "Prohibited"
exit

[
  League,
  Game,
  Team,
].each do |model|
  STDOUT.puts "Destroying all #{model}..."
  model.destroy_all
end

result_chart = PlayResultChart.first

offensive_strategy = OffensiveStrategy.first
defensive_strategy = DefensiveStrategy.first

home_team = Team.create!(
  name:               'Home Team',
  abbr:               'H',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
).tap { |t| t.create_team_trait! }
visitors  = Team.create!(
  name:               'Visitors',
  abbr:               'V',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
).tap { |t| t.create_team_trait! }

Game.create!(home_team: home_team, visitors: visitors)

Team.create!(
  name:               'Miami',
  abbr:               'MIA',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
).create_team_trait!(
  run_yardage:      -3,
  run_breakaway:    -3,
  pass_short:        5,
  pass_long:         5,
  pass_breakaway:    5,
  pass_protect:      5,
  qb_mobility:      -5,

  run_defense:       0,
  run_tackling:      0,
  pass_rush:         3,
  pass_coverage:     0,
  pass_tackling:     0,

  place_kicking:     4,
  return_breakaway:  0,
  return_coverage:   0,
)

Team.create!(
  name:               'N.Y. Jets',
  abbr:               'NYJ',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
).create_team_trait!(
  run_yardage:       1,
  run_breakaway:     1,
  pass_short:        0,
  pass_long:        -1,
  pass_breakaway:   -2,
  pass_protect:     -1,
  qb_mobility:       3,

  run_defense:       1,
  run_tackling:      1,
  pass_rush:         0,
  pass_coverage:     0,
  pass_tackling:     0,

  place_kicking:    -1,
  return_breakaway:  0,
  return_coverage:   0,
)

Team.create!(
  name:               'Chicago',
  abbr:               'CHI',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
).create_team_trait!(
  run_yardage:       4,
  run_breakaway:     4,
  pass_short:        2,
  pass_long:         0,
  pass_breakaway:    0,
  pass_protect:     -3,
  qb_mobility:       4,

  run_defense:       5,
  run_tackling:      4,
  pass_rush:         5,
  pass_coverage:     0,
  pass_tackling:    -2,

  place_kicking:     2,
  return_breakaway:  2,
  return_coverage:   2,
)

Team.create!(
  name:               'Green Bay',
  abbr:               'GB',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
).create_team_trait!(
  run_yardage:       3,
  run_breakaway:     2,
  pass_short:        3,
  pass_long:         2,
  pass_breakaway:    2,
  pass_protect:      1,
  qb_mobility:       3,

  run_defense:       2,
  run_tackling:      3,
  pass_rush:         2,
  pass_coverage:     3,
  pass_tackling:     2,

  place_kicking:     5,
  return_breakaway:  5,
  return_coverage:   5,
)

Team.create!(
  name:               'Baltimore',
  abbr:               'BAL',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
).create_team_trait!(
  run_yardage:       5,
  run_breakaway:     5,
  pass_short:        4,
  pass_long:         3,
  pass_breakaway:    2,
  pass_protect:      2,
  qb_mobility:       5,

  run_defense:      -2,
  run_tackling:     -3,
  pass_rush:        -1,
  pass_coverage:     3,
  pass_tackling:     4,

  place_kicking:     3,
  return_breakaway:  3,
  return_coverage:   3,
)

teams = Team.where.not(abbr: %w[H V])
League.create!(name: 'National Football', year: 1961, teams: teams)
