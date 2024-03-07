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
      time = offensive_play.punt? ? 2000 : 1000
      announcement.add("Snap", time)
      time = offensive_play.normal? ? 1000 : 2500
      announcement.add(*first_announce(offensive_play, play))
      if offensive_play.play_action_pass?
        announcement.add("Play fake", 1000)
        announcement.add("Back to throw", 1000)
      elsif offensive_play.razzle_dazzle?
        announcement.add("Pitch back to QB", 2000)
      end
      announcement.add("BLITZ", 1000) if (offensive_play.pass? || offensive_play.draw?) && game&.defensive_play&.blitz?
    elsif offensive_play.onside_kickoff?
      announcement.add("Onside kick", 2500)
      rec_by = play.fumble_rec_by_own? ? 'KICKING' : 'receiving'
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
    if play.field_goal_try? || play.extra_point_try? || play.kick_blocked?
      time = play.punt_blocked? ? 2000 : 1500
      announcement.add("Snap", time)
      if play.kick_blocked?
        text = play.field_goal_blocked? ? "Kick is" : "Punt"
        announcement.add(text, 500)
        announcement.add("BLOCKED!", 1500)
        lands_on = run_from + play.air_yardage
        if lands_on <= -10
          announcement.add("Ball gets out of end zone", 1000)
          announcement.add("SAFETY", 1000)
        else
          team = play.fumble_rec_by_own? ? "own" : "OPPONENT"
          if play.blocked_kick_return?
            run_from += play.air_yardage
            run_from = 100 - run_from
            run_yardage_after = play.air_yardage - play.yardage
            announcement.add("Picked up by #{team} #{at_yard_line(run_from)}", 1500)
          else
            where, time = lands_on <= 0 ? ["in zone", 1000] : [at_yard_line(game.ball_on), 2000]
            announcement.add("Recovered by #{team} #{where}", time)
            announcement.add(play.fumble_rec_by_opponent? ? "TOUCHDOWN" : "SAFETY", 1000) if lands_on <= 0
          end
        end
      else
        announcement.add("Kick is up", 1000)
        time = (100 - run_from + 7 + 10) * 50 - 200
        announcement.add("Kick is up, and it is", time)
        result = play.no_scoring? ? 'NO GOOD' : 'GOOD'
        announcement.add("Kick is up, and it is #{result}", 2000)
      end
    elsif play.sacked?
      time = [play.air_yardage / 10.0 * 1200, 1000].max * rand(1.0 .. 2.0)
      announcement.set_time_to_last(time)
      announcement.add("Under pressure", 1000 * rand(1.0 .. 1.5))

      yard_at = run_from + play.yardage
      in_zone = play.safety? || yard_at <= 0
      text = "SACKED" + (in_zone ? " IN ZONE" : "")
      announcement.show_ball_marker(yard_at, is_home_team: home_had_ball_at_start?(game, play))
      if play.fumble?
        announcement.add(text, 500)
        announcement.add("FUMBLE", 2500)
        text = play.fumble_rec_by_own? ? "Recovered by own" : "RECOVERED BY OPPONENT"
        announcement.add(text, 2000)
        announcement.add(play.fumble_rec_by_own? ? "SAFETY" : "TOUCHDOWN", 1000) if in_zone
      else
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
        else
          0
        end
      if play.pass?
        is_in_zone = true if run_from >= 100
        announcement.add("Under pressure", 1000 * rand(1.0 .. 1.5)) if rand(2).zero? && !offensive_play.hail_mary?
        time = [play.air_yardage / 10.0 * 1200, 1000].max
        announcement.set_time_to_last(time * rand(1.0 .. 1.5))
        time = [play.air_yardage / 10.0 * 800, 1000].max
        where = is_in_zone ? ' into zone' : play.air_yardage <= 0 ? ' flat' : ''
        if is_in_zone && time >= 1600
          time_throws_only = time - 800
          announcement.add("Throws", time_throws_only)
          announcement.fly_ball_marker(play, game, time: 750)
          announcement.add("Into zone", time - time_throws_only)
        else
          text = offensive_play.screen_pass? ? "Screen" : "Throws" + where
          announcement.add(text, time / 2)
          announcement.fly_ball_marker(play, game, time: 750)
          announcement.add(text, time / 2)
        end
        if play.complete? && play.air_yardage > 15 && run_yardage_after >= 5 && rand(3).zero?
          announcement.add_time_to_last(-500)
          announcement.add("Wide open", 500)
        end
        text = play.result.to_s.upcase
        text += ' ' + at_yard_line(run_from) unless is_in_zone
        announcement.add(text, 1000)
      else  # kick_and_return
        announcement.fly_ball_marker(play, game, time: 2000)
        if play.no_return?
          announcement.add("Into zone", 1000) if run_from <= 0
        else
          announcement.show_ball_marker(run_from, is_home_team: !home_had_ball_at_start?(game, play))
          announcement.add("From #{at_yard_line(run_from, only_yardage: true)}", 1000)
        end
      end
    end

    if play.on_ground? || play.complete? || play.intercepted? || play.kick_and_return? || play.blocked_kick_return?
      if offensive_play.draw?
        time = play.yardage < 0 ? 500 : 1000
        announcement.add("Hand off", time)
      elsif offensive_play.reverse?
        announcement.add("Reverse", 2000)
      end
      is_long_gain = false
      if play.yardage >= 5 || (play.possession_changing? && play.no_fumble?) || play.blocked_kick_return?
        if play.on_ground? && play.yardage >= 5
          text = if offensive_play.sweep? || offensive_play.reverse? || (offensive_play.slant? && rand(4).zero?)
                   "Turn the corner"
                 else
                   "Nice hole"
                 end
          time = 500 + 150 * [play.yardage, 10].min
          announcement.add(text, time)
        end
        if    (play.on_ground? && play.yardage >= 10) \
           || (play.pass? && !play.intercepted? && run_yardage_after > 5) \
           || ((play.kick_and_return? || play.intercepted?) && !play.no_return?) \
           || play.blocked_kick_return?
          start_on = play.on_ground? ? (run_from + 10) / 10 * 10 : run_from
          end_on = if play.touchdown?
                     100
                   elsif play.blocked_kick_return?
                     run_from + run_yardage_after
                   elsif play.fumble_rec_by_opponent?
                     100 - game.ball_on
                   else
                     game.ball_on
                   end
          home_moving_ball = (
            game.home_has_ball && !play.fumble_rec_by_opponent?
          ) || (
            !game.home_has_ball && play.fumble_rec_by_opponent?
          )
          prev_yard = start_on > 50 ? 50 : 0
          long_gain_statements(start_on, end_on).each do |text, time|
            yard = text.gsub(/\D/, '').to_i
            yard = 100 - yard if yard < prev_yard
            announcement.show_ball_marker(yard, is_home_team: home_moving_ball) if yard > 0
            announcement.add(text, time)
            prev_yard = yard
          end
          is_long_gain = true
        end
      end

      yard_for_announcement = nil
      text = \
        if play.fumble? && !play.blocked_kick_return?
          announcement.add("FUMBLE #{at_yard_line(game.ball_on, no_side: true)}", 2500)
          yard_for_announcement = game.ball_on
          play.fumble_rec_by_own? ? "Recovered by own" : "RECOVERED BY OPPONENT"
        elsif play.no_scoring?
          verb = (play.no_return? && play.punt_and_return?) ? "Fair catch" \
                                      : play.out_of_bounds? ? "Out of bounds" : "Stopped"
          yard_for_announcement = game.ball_on
          if play.possession_changing? || play.blocked_kick_return?
            if play.no_return? && run_from <= 0
              yard_for_announcement = nil
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
            at = is_long_gain || game.ball_on > 90 ? " #{at_yard_line(game.ball_on)}" : ""
            "#{verb}#{at} for #{play.yardage} yard gain"
          end
        else
          if play.touchdown? && !is_in_zone
            announcement.show_ball_marker(101, is_home_team: game.home_has_ball)
            announcement.add("Into zone", 500)
          end
          play.scoring.upcase
        end
      announcement.show_ball_marker(yard_for_announcement, is_home_team: game.home_has_ball)
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
        when 1, 2, 4, 8, 9, 31
          time -= 500 if play.yardage < 0 || offensive_play.play_action_pass?
          time += 500 if offensive_play.razzle_dazzle?
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

    def at_yard_line(ball_on, only_yardage: false, no_side: false)
      side = ''
      side = ball_on < 50 ? 'own ' : 'opponent ' if !no_side && ball_on.between?(30, 70) && ball_on != 50
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
        [prefix + at_yard_line(ball_on, only_yardage: true), [time, 750].max]
      }
    end

    def home_had_ball_at_start?(game, play)
      ( game.home_has_ball && !play.possession_changed?) \
        || \
      (!game.home_has_ball &&  play.possession_changed?)
    end
end
