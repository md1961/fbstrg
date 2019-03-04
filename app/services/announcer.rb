module Announcer
  module_function

  def announce(play, game = nil)
    if game.nil?
      game = play.game_snapshot
      game.offensive_play = play.offensive_play
      game.previous_spot = game.ball_on
      def game.ball_on
        previous_spot + play.yardage
      end
    end

    offensive_play = game.offensive_play
    announcement = Views::Announcement.new
    return announcement unless offensive_play
    if offensive_play.kneel_down?
      announcement.add("Kneel down", 2000)
      return announcement
    elsif offensive_play.spike_ball?
      announcement.add("Spike the ball", 2000)
      return announcement
    end
    if offensive_play.normal? || offensive_play.hail_mary? || (offensive_play.punt? && !play.punt_blocked?)
      announcement.add("Snap", 1000)
      time = offensive_play.normal? ? 1000 : 2500
      announcement.add(*first_announce(offensive_play, play))
    elsif offensive_play.onside_kickoff?
      announcement.add("Onside kick", 2500)
      rec_by = play.fumble_rec_by_own? ? 'kicking' : 'receiving'
      announcement.add("Recovered by #{rec_by} team", 2000)
      return announcement
    elsif offensive_play.kickoff?
      announcement.add("Kickoff", 2500)
    elsif offensive_play.kickoff_after_safety?
      announcement.add(*first_announce(offensive_play, play))
    end

    run_from = game.previous_spot || game.game_snapshots.order(:play_id).last&.ball_on
    run_yardage_after = 0
    is_in_zone = false
    if play.field_goal_try? || play.extra_point_try? || play.field_goal_blocked? || play.punt_blocked?
      announcement.add("Snap", 1000)
      if play.field_goal_blocked? || play.punt_blocked?
        announcement.add("BLOCKED", 1500)
        dead_on = run_from + play.yardage
        if dead_on <= -10
          announcement.add("Ball gets out of end zone", 2000)
        else
          team = play.fumble_rec_by_own? ? "own" : "OPPONENT"
          where = dead_on <= 0 ? "in zone" : at_yard_line(game.ball_on)
          announcement.add("Recovered by #{team} #{where}", 2000)
        end
      else
        announcement.add("Kick is up", 1000)
        time = (100 - run_from + 7 + 10) * 50 - 200
        announcement.add("Kick is up, and it's", time)
        result = play.no_scoring? ? 'NO GOOD' : 'GOOD'
        announcement.add("Kick is up, and it's #{result}", 2000)
      end
    elsif play.sacked?
      time = [play.air_yardage / 10.0 * 1200, 1000].max * rand(1.0 .. 2.0)
      announcement.set_time_to_last(time)
      announcement.add("Under pressure", 1000 * rand(1.0 .. 1.5))
      if play.fumble?
        announcement.add("FUMBLE", 2500)
        text = play.fumble_rec_by_own? ? "Recovered by own" : "RECOVERED BY OPPONENT"
        announcement.add(text, 2000)
      else
        text = "SACKED" + (play.safety? ? " IN ZONE" : "")
        announcement.add(text, 1000)
        if play.safety?
          announcement.add("SAFETY", 1000)
        else
          announcement.add("Down #{at_yard_line(game.ball_on)}", 2000)
        end
      end
    elsif play.pass? || play.kick_and_return?
      run_from += play.air_yardage
      run_from = 100 - run_from if play.intercepted? || play.kick_and_return?
      run_yardage_after = \
        if play.complete?
          play.yardage - play.air_yardage
        elsif play.possession_changing?
          play.air_yardage - play.yardage
        end
      if play.pass?
        time = [play.air_yardage / 10.0 * 1200, 1000].max
        announcement.add("Under pressure", 1000 * rand(1.0 .. 1.5)) if rand(2).zero? && !offensive_play.hail_mary?
        announcement.set_time_to_last(time * rand(1.0 .. 1.5))
        time = [play.air_yardage / 10.0 * 800, 1000].max
        text = offensive_play.screen_pass? ? "Screen pass" : "Throws"
        announcement.add(text, time)
        text = "#{play.result.to_s.upcase} #{at_yard_line(run_from)}"
        announcement.add(text, 1000)
        is_in_zone = true if run_from >= 100
      elsif play.no_return?
        announcement.add("Into zone", 1000) if run_from <= 0
      else # kick_and_return?
        announcement.add("From #{at_yard_line(run_from, true)}", 1000)
      end
    end

    if play.on_ground? || play.complete? || play.intercepted? || play.kick_and_return?
      if offensive_play.draw?
        time = play.yardage < 0 ? 500 : 1000
        announcement.add("Hand off", time)
      elsif offensive_play.reverse?
        announcement.add("Reverse", 2000)
      end
      is_long_gain = false
      if play.yardage >= 5 || (play.possession_changing? && play.no_fumble?)
        announcement.add("Find hole!", 1000 + 150 * [play.yardage, 10].min) if play.on_ground?
        if    (play.on_ground? && play.yardage >= 10) \
           || (play.pass? && !play.intercepted? && run_yardage_after > 5) \
           || ((play.kick_and_return? || play.intercepted?) && !play.no_return?)
          start_on = play.on_ground? ? (run_from + 10) / 10 * 10 : run_from
          end_on = play.fumble_rec_by_opponent? ? 100 - game.ball_on : game.ball_on
          long_gain_statements(start_on, end_on).each do |text, time|
            announcement.add(text, time)
          end
          is_long_gain = true
        end
      end
      text = \
        if play.fumble?
          announcement.add("FUMBLE #{at_yard_line(game.ball_on)}", 2500)
          play.fumble_rec_by_own? ? "Recovered by own" : "RECOVERED BY OPPONENT"
        elsif play.no_scoring?
          verb = (play.no_return? && play.punt_and_return?) ? "Fair catch" \
                                      : play.out_of_bounds? ? "Out of bounds" : "Stopped"
          if play.possession_changing?
            if play.no_return? && run_from <= 0
              "Touchback"
            else
              verb = "Ball dead" if play.no_return? && run_from < 10
              "#{verb} #{at_yard_line(game.ball_on)}"
            end
          elsif play.yardage < 0
            "#{verb} behind the line of scrimmage"
          elsif play.yardage.zero?
            "#{verb} at the line of scrimmage"
          else
            at = is_long_gain ? " #{at_yard_line(game.ball_on)}" : ""
            "#{verb}#{at} for #{play.yardage} yard gain"
          end
        else
          announcement.add("Into zone", 500) if play.touchdown? && !is_in_zone
          play.scoring.upcase
        end
      announcement.add(text, 2000)
    end
    announcement.set_time_to_last(2000)
    announcement
  end

    def first_announce(offensive_play, play)
      if offensive_play.punt? || offensive_play.kickoff_after_safety?
        if play.air_yardage < 30
          return ["Wobbling punt", 2000]
        elsif play.air_yardage > 50
          return ["Booming punt", 3000]
        else
          return ["Punt", 2500]
        end
      end

      time = 1000
      text = \
        case offensive_play.number
        when 1, 2, 4, 8
          time -= 500 if play.yardage < 0
          "Hand off"
        when 3
          "Quarterback keep"
        when 5, 6
          time = 2000 if offensive_play.sweep?
          "Pitch"
        when 7, 10 .. 20, 601
          time = 1500
          "Back to throw"
        when 9
          time = 1500
          play.on_ground? ? "Hand off" : "Back to throw"
        else
          "???"
        end
      [text, time]
    end

    def at_yard_line(ball_on, only_yardage = false)
      side = ''
      side = ball_on < 50 ? 'own ' : 'opponent ' if ball_on.between?(30, 70) && ball_on != 50
      return "in zone" if ball_on <= 0 || ball_on >= 100
      yardage = ball_on <= 50 ? ball_on : 100 - ball_on
      return yardage.to_s if only_yardage
      "at #{side}#{yardage} yard line"
    end

    def long_gain_statements(start_on, end_on)
      start_on = [(start_on.to_i + 4) / 5 * 5,  5].max
      end_on   = [(end_on  .to_i - 1) / 5 * 5, 95].min
      time = 1000
      start_on.step(end_on, 5).map { |ball_on|
        prefix = start_on == ball_on ? "To the " : ""
        time -= 50
        [prefix + at_yard_line(ball_on, true), [time, 750].max]
      }
    end
end
