module Announcer
  module_function

  # | 1  | 1      | Power Up Middle      | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 2  | 2      | Power Off Tackle     | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 3  | 3      | Quarterback Keep     | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 4  | 4      | Slant                | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 5  | 5      | Sweep                | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 6  | 6      | Reverse              | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 7  | 7      | Draw                 | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 8  | 8      | Trap                 | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 9  | 9      | Run Pass Option      | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 10 | 10     | Flair Pass           | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 11 | 11     | Sideline Pass        | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 12 | 12     | Look-In Pass         | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 13 | 13     | Screen Pass          | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 14 | 14     | Pop Pass             | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 15 | 15     | Button Hook Pass     | 2019-01-15 22:31:44 UTC | 2019-01-15 22:31:44 UTC |
  # | 16 | 16     | Razzle Dazzle        | 2019-01-15 22:31:45 UTC | 2019-01-15 22:31:45 UTC |
  # | 17 | 17     | Down & Out Pass      | 2019-01-15 22:31:45 UTC | 2019-01-15 22:31:45 UTC |
  # | 18 | 18     | Down & In Pass       | 2019-01-15 22:31:45 UTC | 2019-01-15 22:31:45 UTC |
  # | 19 | 19     | Long Bomb            | 2019-01-15 22:31:45 UTC | 2019-01-15 22:31:45 UTC |
  # | 20 | 20     | Stop & Go Pass       | 2019-01-15 22:31:45 UTC | 2019-01-15 22:31:45 UTC |
  def announce(play, game)
    offensive_play = game.offensive_play
    announcement = Views::Announcement.new
    if offensive_play.normal? || offensive_play.punt?
      announcement.add("Snap", 1000)
      time = offensive_play.normal? ? 1000 : 2500
      announcement.add(*first_announce(offensive_play, play))
    elsif offensive_play.kickoff?
      announcement.add("Kickoff", 1500)
    end

    run_from = game.previous_spot || game.game_snapshots.order(:play_id).last&.ball_on
    air_yardage = 0
    run_yardage_after = 0
    if play.sacked?
      air_yardage = determine_air_yardage(offensive_play, play)
      time = [air_yardage / 10.0 * 1000, 1000].max + rand(0 .. 2000)
      text = "SACKED" + (play.scoring == 'SAFETY' ? " IN ZONE" : "")
      announcement.add(text, time)
      if play.scoring == 'SAFETY'
        announcement.add("SAFETY", 1000)
      else
        announcement.add("Down #{at_yard_line(game.ball_on)}", 1000)
      end
    elsif play.throw? || play.kick_and_return?
      air_yardage = determine_air_yardage(offensive_play, play)
      run_from += air_yardage
      run_from = 100 - run_from if play.possession_changing?
      run_yardage_after = \
        if play.complete?
          play.yardage - air_yardage
        elsif play.possession_changing?
          air_yardage - play.yardage
        end
      if play.throw?
        time = [air_yardage / 10.0 * 1500, 1000].max + rand(0 .. 1000)
        announcement.add("Throws", time)
        text = "#{play.result.to_s.upcase} #{at_yard_line(run_from)}"
        announcement.add(text, time)
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
        if play.yardage >= 10 || (play.throw? && run_yardage_after > 5) || play.kick_and_return?
          start_on = play.on_ground? ? (run_from + 10) / 10 * 10 : run_from
          long_gain_statements(start_on, game.ball_on).each do |text, time|
            announcement.add(text, time)
          end
          is_long_gain = true
        end
      end
      text = \
        if !play.no_fumble?
          announcement.add("FUMBLE #{at_yard_line(game.ball_on)}", 2500)
          play.fumble_rec_by_own? ? "Recovered by own" : "RECOVERED BY OPP"
        elsif play.scoring.blank?
          if play.possession_changing?
            "Down #{at_yard_line(game.ball_on)}"
          elsif play.yardage < 0
            "Stopped behind the scrimmage"
          elsif play.yardage.zero?
            "Stopped at the scrimmage"
          else
            at = is_long_gain ? " #{at_yard_line(game.ball_on)}" : ""
            "Stopped#{at} for #{play.yardage} yard gain"
          end
        else
          announcement.add("Into zone", 500) if play.scoring.downcase == 'touchdown'
          play.scoring
        end
      announcement.add(text, 2000)
    end
    announcement
  end

    def first_announce(offensive_play, play)
      return ["Punt", 2500] if offensive_play.punt?

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
        when 7, 10 .. 20
          "Drop back"
        when 9
          play.on_ground? ? "Hand off" : "Drop back"
        else
          "???"
        end
      [text, time]
    end

    def at_yard_line(ball_on, only_yardage = false)
      return "in zone" if ball_on <= 0 || ball_on >= 100
      yardage = ball_on <= 50 ? ball_on : 100 - ball_on
      return yardage.to_s if only_yardage
      "at #{yardage} yard line"
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

    def determine_air_yardage(offensive_play, play)
      return rand(55 .. 65) if offensive_play.kickoff?
      return rand(40 .. 50) if offensive_play.punt?
      min = offensive_play.min_throw_yard
      max = offensive_play.max_throw_yard
      min = [min, play.yardage].max if play.intercepted?
      max = [max, play.yardage].min if play.complete?
      rand(min .. max)
    end
end
