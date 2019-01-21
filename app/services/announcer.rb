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
    if offensive_play.normal?
      announcement.add("Snap", 1000)
      announcement.add(first_statement(offensive_play, play), 1000)
    elsif offensive_play.kickoff?
      announcement.add("Kickoff", 1000)
    end

    run_from = game.previous_spot || game.game_snapshots.order(:play_id).last&.ball_on
    air_yargage = 0
    run_yardage_after = 0
    if play.sacked?
      air_yargage = determine_air_yargage(offensive_play, play)
      timeout = [air_yargage / 10.0 * 1000, 1000].max + rand(0 .. 2000)
      text = "SACKED" + (play.scoring == 'SAFETY' ? " IN ZONE" : "")
      announcement.add(text, timeout)
      if play.scoring == 'SAFETY'
        announcement.add("SAFETY", 1000)
      else
        announcement.add("Down #{at_yard_line(game.ball_on)}", 1000)
      end
    elsif play.throw? || play.kickoff_and_return?
      air_yargage = determine_air_yargage(offensive_play, play)
      run_from += air_yargage
      run_from = 100 - run_from if play.possession_changing?
      run_yardage_after = \
        if play.complete?
          play.yardage - air_yargage
        elsif play.possession_changing?
          air_yargage - play.yardage
        end
      if play.throw?
        timeout = [air_yargage / 10.0 * 1000, 1000].max + rand(0 .. 1000)
        announcement.add("Throws", timeout)
        text = "#{play.result.to_s.upcase} #{at_yard_line(run_from)}"
        announcement.add(text, timeout)
      else # kickoff_and_return?
        announcement.add("From the #{at_yard_line(run_from, true)}", rand(2000 .. 2500))
      end
    end
    if play.on_ground? || play.complete? || play.intercepted? || play.kickoff_and_return?
      announcement.add("Hand off", 1000) if offensive_play.draw?
      announcement.add("Reverse", 2000) if offensive_play.reverse?
      time_add = offensive_play.sweep? ? 1000 : 0
      is_long_gain = false
      if play.yardage >= 5 || play.possession_changing?
        announcement.add("Find hole!", 1000 + time_add) if play.on_ground?
        time_add = 0
        if play.yardage >= 10 || (play.throw? && run_yardage_after > 5) || play.kickoff_and_return?
          start_on = play.on_ground? ? (run_from + 10) / 10 * 10 : run_from
          long_gain_statements(start_on, game.ball_on).each do |text, timeout|
            announcement.add(text, timeout)
          end
          is_long_gain = true
        end
      end
      if play.scoring.blank?
        if play.possession_changing?
          announcement.add("Down #{at_yard_line(game.ball_on)}", 1500)
        elsif play.yardage < 0
          announcement.add("Stopped behind the scrimmage", 500 + time_add)
        elsif play.yardage.zero?
          announcement.add("Stopped at the scrimmage", 1000 + time_add)
        else
          at = is_long_gain ? " #{at_yard_line(game.ball_on)}" : ""
          announcement.add("Stopped#{at} for #{play.yardage} yard gain", 1500 + time_add)
        end
      else
        announcement.add("Into zone", 500) if play.scoring.downcase == 'touchdown'
        announcement.add(play.scoring, 1000)
      end
    end
    announcement.add('__END__', 2000) unless announcement.empty?
    announcement
  end

    def first_statement(offensive_play, play)
      case offensive_play.number
      when 1, 2, 4, 6, 8
        "Hand off"
      when 3
        "Quarterback keep"
      when 5, 6
        "Pitch"
      when 7, 10 .. 20
        "Drop back"
      when 9
        play.on_ground? ? "Hand off" : "Drop back"
      end
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
      timeout = 1000
      start_on.step(end_on, 5).map { |ball_on|
        prefix = start_on == ball_on ? "To the " : ""
        timeout -= 50
        [prefix + at_yard_line(ball_on, true), [timeout, 750].max]
      }
    end

    def determine_air_yargage(offensive_play, play)
      return rand(55 .. 65) if offensive_play.kickoff?
      min = offensive_play.min_throw_yard
      max = offensive_play.max_throw_yard
      min = [min, play.yardage].max if play.intercepted?
      max = [max, play.yardage].min if play.complete?
      rand(min .. max)
    end
end
