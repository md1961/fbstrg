class Game < ActiveRecord::Base
  attr_accessor :error_message

  KICKOFF_YARDLINE = 35
  TOUCHBACK_YARDLINE = 20

  RE_PLAY_VALUE = /\A(?<kind>[a-z]*)(?<yard>-?[0-9]+)/

  def play(value)
    self.error_message = nil
    m = value.match(RE_PLAY_VALUE)
    unless m
      self.error_message = "Illegal play '#{value}'"
      return
    end
    kind = m[:kind]
    kind = 'r' if kind.blank?
    yard = Integer(m[:yard])

    case kind
    when 'r'
      yardage_play(yard)
    when 'x'
      change_possesion(yard)
    else
      self.error_message = "Illegal kind '#{kind}'"
    end
  end

  private

    def toggle_possesion
      self.is_ball_to_home = !is_ball_to_home
      self.ball_on = 100 - ball_on
    end

    def firstdown
      self.down = 1
      self.yard_to_go = 10
    end

    def touchdown
      if is_ball_to_home
        self.score_home += 7
      else
        self.score_visitors += 7
      end
      firstdown
      self.ball_on = KICKOFF_YARDLINE
    end

    def touchback
      self.ball_on = 100 - TOUCHBACK_YARDLINE
    end

    def yardage_play(yard)
      self.ball_on += yard
      if ball_on >= 100
        touchdown
      else
        self.yard_to_go -= yard
        self.down += 1
        if yard_to_go <= 0
          firstdown
        elsif down > 4
          toggle_possesion
          firstdown
        end
      end
      self.time_left -= 40
    end

    def change_possesion(yard)
      self.ball_on += yard
      touchback if ball_on >= 100
      toggle_possesion
      firstdown
      self.time_left -= 10
    end
end
