module Clocker
  module_function

  def time_to_take(play, game)
    play.time_to_take = 0 if play.extra_point_try? || game.two_point_try
    game.clock_stopped = play.incomplete? || play.intercepted? || play.fumble_rec_by_opponent? \
                      || play.field_goal_try? || play.kick_and_return? || play.onside_kick? \
                      || play.extra_point_try? || game.two_point_try \
                      || play.penalty? || !play.no_scoring? || play.possession_changed? \
                      || (play.out_of_bounds? && clock_stops_when_out_of_bounds?(game, play))
    play.time_to_take
  end

    def clock_stops_when_out_of_bounds?(game, play)
      time_left = game.time_left - play.time_to_take
      (game.quarter == 2 && time_left <= 2 * 60) || (game.quarter >= 4 && time_left <= 5 * 60)
    end
end
