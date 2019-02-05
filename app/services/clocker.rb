module Clocker
  module_function

  def time_to_take(play, game)
    play.time_to_take = 0 if play.extra_point?
    game.clock_stopped = play.incomplete? || play.intercepted? || play.fumble_rec_by_opponent? ||
                            play.field_goal? || play.kick_and_return? || play.penalty? ||
                            play.scoring.present? ||
                            (play.out_of_bounds? && clock_stops_when_out_of_bounds?(game))
    play.time_to_take
  end

    def clock_stops_when_out_of_bounds?(game)
      (game.quarter == 2 && game.time_left <= 2 * 60) || (game.quarter >= 4 && game.time_left <= 5 * 60)
    end
end
