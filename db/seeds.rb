# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

OFFENSIVE_PLAYS = [
  [ 1, 'Power Up Middle'],
  [ 2, 'Power Off Tackle'],
  [ 3, 'Quarterback Keep'],
  [ 4, 'Slant'],
  [ 5, 'End Run'],
  [ 6, 'Reverse'],
  [ 7, 'Draw'],
  [ 8, 'Trap'],
  [ 9, 'Run Pass Option'],
  [10, 'Flair Pass'],
  [11, 'Sideline Pass'],
  [12, 'Look-In Pass'],
  # Cannot call below at 1-10 yard line.
  [13, 'Screen Pass'],
  [14, 'Pop Pass'],
  [15, 'Button Hook Pass'],
  [16, 'Razzle Dazzle'],
  # Cannot call below at 1-20 yard line.
  [17, 'Down & Out Pass'],
  [18, 'Down & In Pass'],
  [19, 'Long Bomb'],
  [20, 'Stop & Go Pass'],

  # For the followings, use alphabets and spaces ONLY for a name to .gsub(/\s+/, '').underscore makes a variable name.
  [101, 'Kickoff'],
  [102, 'Squib Kickoff'],
  [103, 'Onside Kickoff'],
  [201, 'Punt'],
  [202, 'Coffin Corner Punt'],
  [301, 'Field Goal'],
  [401, 'Extra Point'],
  [402, 'Two Point Conversion'],
  [501, 'Kneel Down'],
]
OffensivePlay.create!(OFFENSIVE_PLAYS.map { |values|
  Hash[%w(number name).zip(values)]
})

OFFENSIVE_PLAY_SETS = [
  ['Dumb Even'   , [100] * 20],
  #                   1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20
  ['Standard'    , [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,  10,  50,  50,  50,  50]],
  ['Aggresive'   , [ 20,  20,   0,  70, 100, 100, 100,  70, 100,  70,  70,  70, 100, 100, 100,  50, 100, 100, 100, 100]],
  ['Ball Control', [100, 100, 100, 100,  70,  50,  70,  80,  10,  70,  70,  70,  70,  40,  40,   0,   5,   5,   5,   5]],
  ['Protect'     , [100, 100, 100, 100, 100,  50,  50, 100,   0,  50,  50,  50,   0,   0,   0,   0,   0,   0,   0,   0]],
  ['Aim Short'   , [100, 100, 100, 100, 100, 100, 100, 100,  50,  50,  50,  50,  50,  50,  50,  10,  20,  20,  20,  20]],
  ['Aim Long'    , [  0,   0,   0,  20,  50,  50,  60,  50,  50,  70,  70,  70, 100, 100, 100,  50,  80,  80,  80,  80]],
  ['Hurry Up'    , [ 10,  10,   0,  50,  70,  50,  50,  50,  80,  70, 120,  70,  70, 100, 100,  50, 100, 100, 100, 100]],
  ['Goal Line'   , [100, 100, 100, 100, 100,  80,  80, 100,  50,  50,  50,  50,   0,   0,   0,   0,   0,   0,   0,   0]],
]

offensive_plays = OffensivePlay.where('number < 100').order(:number)
OFFENSIVE_PLAY_SETS.each do |name, weights|
  off_set = OffensivePlaySet.create!(name: name)
  unless weights.size == offensive_plays.size
    raise StandardError, "Number of weights (#{weights.size} vs #{offensive_plays.size}) for offensive set '#{name}'"
  end
  offensive_plays.zip(weights) do |offensive_play, weight|
    off_set.offensive_play_set_choices.create!(offensive_play: offensive_play, weight: weight)
  end
end

PUNTS = [
  ['Punt 4th Down Only'],
  ['Punt Any Down'],
]

DEFENSIVE_PLAYS = [
#         L   LB      CB   SF   Run          Pass
  ['A', '8', '0'   , '3', '0', 'Excellent' , 'Terrible'],
  ['B', '7', '0'   , '4', '0', 'Very Good' , 'Very Poor'],
  ['C', '6', '2Blz', '3', '0', 'Very Good Outside, Poor Up Middle', 'Good On Long, Very Poor On Short'],
  ['D', '5', '3'   , '3', '0', 'Good'      , 'Bad'],
  ['E', '4', '3'   , '4', '0', 'Faily Good', 'Fair'],
  ['F', '4', '3'   , '3', '1', 'Fair'      , 'Fairly Good'],
  ['G', '4', '3'   , '2', '2', 'Bad'       , 'Good'],
  ['H', '4', '3Blz', '2', '2', 'Good Outside, Very Poor Up Middle', 'Very Good On Long, Good On Short'],
  ['I', '4', '0'   , '3', '4', 'Very Poor' , 'Very Good'],
  ['J', '3', '0'   , '3', '5', 'Terrible'  , 'Excellent'],
]
DefensivePlay.create!(DEFENSIVE_PLAYS.map { |values|
  Hash[%w(name lineman linebacker cornerback safety against_run against_pass).zip(values)]
})

DEFENSIVE_PLAY_SETS = [
  ['Dumb Even' , [100] * 10],
  #                 A    B    C    D    E    F    G    H    I    J
  ['Standard'  , [ 20,  40,  70, 100, 100, 100,  70, 100,  40,  20]],
  ['Prevent'   , [  0,   0,  50,  70,  80, 100, 100, 100, 100,  80]],
  ['Expect Run', [ 80, 100, 100, 100,  80,  70,  50,  50,  20,   0]],
  ['Stop Short', [ 90, 100,  50,  80,  60,  50,  40,  20,  10,   0]],
  ['Stop Long' , [  0,   0,  60,  30,  40,  50,  70,  80, 100,  80]],
  ['Slow Down' , [  0,   0,  80,  60,  70,  80, 100, 100,  80,  60]],
  ['Goal Stand', [ 60,  80,  80, 100,  80,  60,  60,  40,  10,   0]],
  ['Goal Line' , [100, 100,  50,  80,  60,  50,  40,  10,   0,   0]],
]

defensive_plays = DefensivePlay.order(:name)
DEFENSIVE_PLAY_SETS.each do |name, weights|
  def_set = DefensivePlaySet.create!(name: name)
  unless weights.size == defensive_plays.size
    raise StandardError, "Number of weights (#{weights.size} vs #{defensive_plays.size}) for defensive set '#{name}'"
  end
  defensive_plays.zip(weights).each do |defensive_play, weight|
    def_set.defensive_play_set_choices.create!(defensive_play: defensive_play, weight: weight)
  end
end

PRO_STYLE_RESULTS = [
  %w(-2 -1 +10 +1 +1 +2 +3 +7 +9 +10),
  %w(-1 fmb -2 +3 +5 +7 +9 -1 +11 +14),
  %w(0 -1 +15 +2 +2 +2 -2_or_pen-5 +15 +5 +5),
  %w(0 +2 -3 +3 +4 +7_or_pen+5 +8 -3 +13 +18),

  %w(-4 -1 fmb pen+15 -3 +6 +9ob +2 +21ob +25ob),
  %w(-2 +1ob -4 fmb +7 +10 +13ob -6 +20ob long),
  %w(+1 +2 -2 +2 +10 -2_or_pen-5 +5 -3 +12 +22),
  %w(+3 -1 +9 +4 +2 0 fmb +15 +9 +11),

  %w(pen-15 cmp+13ob +5 incmp +20 incmp int_opp-25 cmp+25 +5 incmp),
  %w(cmp+3 cmp+6 incmp cmp+5ob cmp+3ob cmp+1 incmp cmp-2 cmp+17ob pen+5af),
  %w(cmp+14ob incmp int_opp+7 cmp+7ob cmp+5ob cmp+4ob cmp+3ob incmp incmp incmp),
  %w(cmp+9 incmp cmp+6 incmp incmp incmp cmp+11 cmp+6 cmp+4 pen-15),

  %w(cmp+18 cmp+15 cmp+9 cmp+6 cmp+4ob sck-10 incmp cmp+12 incmp incmp),
  %w(cmp+19 cmp+16 cmp+11 cmp+8 incmp incmp cmp+4 incmp incmp incmp),
  %w(cmp+16 cmp+13 cmp+8 incmp incmp cmp+16 incmp cmp+7 incmp sck-5),
  %w(long long -15 +11ob pen-15 -20 -15 fmb long long),

  %w(cmp+50ob cmp+45ob cmp+35 cmp+25 incmp cmp+25 incmp sck-15ob int_opp+20 incmp),
  %w(cmp+45 cmp+35 sck-5 cmp+35 cmp+30 int_opp-30 incmp incmp incmp incmp),
  %w(cmp+long cmp+long incmp cmp+35ob sck-15 incmp incmp incmp pen+30af int_opp-30),
  %w(cmp+35 cmp+30 incmp incmp incmp_or_pen-5 incmp cmp+35ob cmp+30ob incmp int_opp-25),
]
result_chart = PlayResultChart.create!(name: 'Pro style')
defensive_plays = DefensivePlay.order(:name)
PRO_STYLE_RESULTS.zip(OffensivePlay.order(:number)) do |row, offensive_play|
  row.zip(defensive_plays) do |result, defensive_play|
    result_chart.play_results.create!(offensive_play: offensive_play, defensive_play: defensive_play, result: result)
  end
end

PUNT_RESULTS = [
  # Punt 4th down only
  %w(70_long 60_10 50_0ob 50_10 40_10 30_0 40_0 60_20 50_0 50_fmb20),
  # Punt any down
  %w(60_0ob blk 50_0ob 60_10 60_0ob 60_0ob 60_10 &0_0 70_0 40_80),
]

KICKOFF_TABLE = [
  # normal, at receiver's yard line
  %w(long 25 25 20 20 15),
  # onside, at kicker's yard line
  %w(k50 k50_or_r50 r50 r45 r45 r40),
]

LONG_GAIN_TABLE = [
  %w(+50_and_again +50 +45 +40 +35 +30),
]

FIELD_GOAL_TABLE = [
  %w(xp     good good good good good good_or_ng),
  %w(1-10   good good good good pen ng),
  %w(11-18  good good good good ng ng),
  %w(19-25  good good good ng ng ng),
  %w(26-32  good good ng ng ng ng),
  %w(33-38  good ng ng ng ng ng),
]

TIME_TABLE = [
  ['20y or more', 45],
  ['less than 20y', 30],
  ['loss', 30],
  ['ob', -15],
  ['int', 30],
  ['incmp', 15],
  ['pen', 15],
  ['fmb', 15],
  ['kicking', 15],
  ['timeout', -30],
]

offensive_strategy = OffensiveStrategy.create!(name: 'Standard')
defensive_strategy = DefensiveStrategy.create!(name: 'Standard')

home_team = Team.create!(
  name:               'Home Team',
  abbr:               'H',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
)
visitors  = Team.create!(
  name:               'Visitors',
  abbr:               'V',
  play_result_chart:  result_chart,
  offensive_strategy: offensive_strategy,
  defensive_strategy: defensive_strategy,
)

Game.create!(home_team: home_team, visitors: visitors)
