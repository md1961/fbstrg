# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

OFFENSE_PLAYS = [
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

DEFENSE_PLAYS = [
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
