H_GAME_ATTRS = {
  score_home:         20,
  score_visitors:     20,
  timeout_home:        2,
  timeout_visitors:    2,
  quarter:             5,
  time_left:         900,
  clock_stopped:    true,
  home_has_ball:   false,
  ball_on:            35,
  down:                1,
  yard_to_go:         10,
  next_play:    :kickoff,
  status:        :huddle,
}

teams = League.order(:updated_at).last.teams.reject(&:human_assisted?).sample(2)
h_teams = %i[visitors home_team].zip(teams).to_h

game = Game.new(h_teams.merge(H_GAME_ATTRS))

begin
  cap = CuiAutoPlayer.new(game)
  cap.play
ensure
  puts "Game(id=#{game.id}) created."

  print "OK to destroy? (y/n) "
  if gets.starts_with?('y')
    game.destroy
  end
end
