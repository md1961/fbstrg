module Clocker
  module_function

  def time_to_take(play, game)
    play.time_to_take = 0 if play.extra_point?
    game.clock_stopped = play.incomplete? || play.intercepted? || play.fumble? ||
      play.out_of_bounds? || play.field_goal? || play.kick_and_return? || play.penalty?
    play.time_to_take
  end
end
