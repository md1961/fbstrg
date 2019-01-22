module Clocker
  module_function

  def time_to_take(play, game)
    t = if play.extra_point?
      0
    elsif play.incomplete? || play.penalty? || play.fumble? || play.field_goal? || play.kick_and_return?
      15
    elsif play.intercepted?
      30
    elsif play.yardage >= 20
      45
    else
      30
    end
    t -= 15 if play.out_of_bounds?
    [t, 0].max.tap do |t|
      play.time_to_take = t
    end
  end
end
