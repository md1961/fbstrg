if ARGV.size > 1
  STDOUT.puts "Too many arguments."
  exit
elsif ARGV.first&.ends_with?('league')
  ARGV.shift
  if League.count.zero?
    STDOUT.puts "No League found."
    exit
  end
  league = League.order(:year).detect { |l| l.next_schedule }
  unless league
    STDOUT.puts "No League has next game to play."
    exit
  end
  schedule = league.next_schedule
  print "OK to play #{schedule}? "
  exit unless gets.chomp == 'y'
  game = schedule.game
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

session = {}
while !game.end_of_game?
  game.no_huddle = session[:no_huddle]
  if game.end_of_quarter? || game.end_of_half?
    game.advance_to_next_quarter
    game.save!
  elsif game.huddle?
    game.determine_offensive_play(game.next_play).tap do |play|
      session[:offensive_play_id]     = play&.id
      session[:offensive_play_set_id] = game.offensive_play_set&.id
      session[:no_huddle] = game.no_huddle
    end
  else
    game.offensive_play     = OffensivePlay   .find_by(id: session[:offensive_play_id])
    game.offensive_play_set = OffensivePlaySet.find_by(id: session[:offensive_play_set_id])
    game.play(game.next_play)
    if game.error_message.present?
      puts game.error_message
      break
    else
      session[:offensive_play_id] = nil
      game.save!
      game.no_huddle = false
      session[:no_huddle] = false

      mins = game.time_left / 60
      time_left_display = format("%d:%02d", mins, game.time_left - mins * 60)
      print "#{game.quarter}Q #{time_left_display}"
      print "#{game.visitors.abbr} #{game.score_visitors} - #{game.home_team.abbr} #{game.score_home}"
      ball_on = game.ball_on
      ball_on_prefix = ball_on == 50 ? '' : ball_on < 50 ? 'Own ' : 'Opp '
      ball_on = 100 - ball_on if ball_on > 50
      print "  #{game.offense.abbr} on #{ball_on_prefix}#{ball_on}"
      print ' ' * 40 + "\r"
    end
  end
end
puts
