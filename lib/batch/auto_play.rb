if ARGV.size > 1
  STDERR.puts "Too many arguments."
  exit
elsif ARGV.first == '--league'
  ARGV.shift
  if League.count.zero?
    STDERR.puts "No League found."
    exit
  end
  league = League.order(:year).detect { |l| l.next_schedule }
  unless league
    STDERR.puts "No League has next game to play."
    exit
  end
  schedule = league.next_schedule
  print "OK to play #{league} #{ApplicationController.helpers.schedule_with_team_result(schedule)} ? "
  exit unless gets.chomp == 'y'
  game = schedule.game
elsif !ARGV.empty?
  STDERR.puts "Illegal option '#{ARGV.first}'"
  exit
else
  last_game = Game.order(:updated_at).last
  home_team = last_game.home_team
  visitors  = last_game.visitors

  teams = []
  while teams.size < 2
    team_type, team = teams.empty? ? ['Home Team', home_team] : ['Visitors', visitors]
    print "Choose #{team_type} by abbr ('' for '#{team.abbr}', 'quit' to quit): "
    name = gets.chomp.upcase
    exit if name == 'QUIT'
    team = Team.where("abbr LIKE ?", "#{name}%").first if name.present?
    next unless team
    teams << team
    puts "'#{team.abbr}' chosen for #{team_type}."
  end

  home_team, visitors = teams
  print "OK to play #{visitors} at #{home_team}? "
  exit unless gets.chomp == 'y'

  game = Game.create!(home_team: home_team, visitors: visitors)
end

cap = CuiAutoPlayer.new(game)
cap.play
