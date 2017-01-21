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
  [13, 'Screen Pass'],
  [14, 'Pop Pass'],
  [15, 'Button Hook Pass'],
  [16, 'Razzle Dazzle'],
  [17, 'Down & Out Pass'],
  [18, 'Down & In Pass'],
  [19, 'Long Bomb'],
  [20, 'Stop & Go Pass'],
]

PUNTS = [
  ['Punt 4th Down Only'],
  ['Punt Any Down'],
]

DEFENSIVE_PLAYS = [
#        L    LB   CB   SF   Run          Pass
  ['A', '8', '-', '3', '-', 'Excellent', 'Terrible'],
  ['B', '7', '-', '4', '-', 'Very Good', 'Very Poor'],
  ['C', '6', '2 Blitz', '3', '-', 'Very Good Outside, Poor Up Middle', 'Good On Long, Very Poor On Short'],
  ['D', '5', '3', '3', '-', 'Good', 'Bad'],
  ['E', '4', '3', '4', '-', 'Faily Good', 'Fair'],
  ['F', '4', '3', '3', '1', 'Fair', 'Fairly Good'],
  ['G', '4', '3', '2', '2', 'Bad', 'Good'],
  ['H', '4', '3 Blitz', '2', '2', 'Good Outside, Very Poor Up Middle', 'Very Good On Long, Good On Short'],
  ['I', '4', '-', '3', '4', 'Very Poor', 'Very Good'],
  ['J', '3', '-', '3', '5', 'Terrible', 'Excellent'],
]

=begin
PRO_STYLE_RESULTS = [
  %w(-2 -1 0 0     -4 -2 +1 +3
     pen-15 cmp+3 cmp+14ob cmp+9  cmp+18 cmp+19 cmp+16 long  cmp+50ob cmp+45 cmp+long cmp+35),
  %w(-1 fmb -1 +2  -1 +1ob +2 -1
     cmp+13ob cmp+6 incmp incmp   cmp+15 cmp+16 cmp+13 long  cmp+45ob cmp+35 cmp+long cmp+30),
  %w(+10 -2 +15 -3  fmb -4 -2 +9
     +5 incmp int_opp+7 cmp+6     cmp+9 cmp+11 cmp+8 -15     cmp+35 sck-5 incmp incmp),
  %w(+1 +3 +2 +3  pen+15 fmb +2 +4
     incmp cmp+5ob cmp+7ob incmp  cmp+6 cmp+8 incmp +11ob    cmp+25 cmp+35 cmp+35ob incmp),
]
=end

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

  # Punt 4th down only
  %w( ),
  # Punt any down
  %w(),
]

