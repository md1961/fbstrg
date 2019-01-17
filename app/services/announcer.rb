module Announcer
  module_function

  # | 1  | 1      | Power Up Middle      | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 2  | 2      | Power Off Tackle     | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 3  | 3      | Quarterback Keep     | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 4  | 4      | Slant                | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
  # | 5  | 5      | End Run              | 2019-01-15 22:31:43 UTC | 2019-01-15 22:31:43 UTC |
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
    announcement.add("Snap", 1000)
    announcement.add(first_statement(offensive_play, play), 1000)
    if play.on_ground?
      time_add = offensive_play.number == 5 ? 1000 : 0
      if play.yardage >= 5
        announcement.add("Find hole!", timeout + time_add)
        time_add = 0
      end
      if play.scoring.blank?
        if play.yardage < 0
          announcement.add("Stopped behind the scrimmage", 500 + time_add)
        elsif play.yardage.zero?
          announcement.add("Stopped at the scrimmage", 1000 + time_add)
        else
          announcement.add("Down for #{play.yardage} yard gain", 2000 + time_add)
        end
      else
        announcement.add(play.scoring, 1000)
      end
    end
    announcement.add('__END__', 2000)
    announcement
  end

    def first_statement(offensive_play, play)
      case offensive_play.number
      when 1, 2, 4, 6, 8
        "Hand off"
      when 3
        "Quarterback keep"
      when 5
        "Pitch"
      when 7, 10 .. 20
        "Drop back"
      when 9
        play.on_ground? ? "Hand off" : "Drop back"
      end
    end
end
