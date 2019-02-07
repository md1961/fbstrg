[
  Team,
  Game
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
