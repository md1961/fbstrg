class Game < ActiveRecord::Base
  attr_accessor :error_message

  KICKOFF_YARDLINE = 35

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

    self.ball_on += yard
    yardage_play(yard)
  end

  private

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

    def yardage_play(yard)
      if ball_on >= 100
        touchdown
      else
        self.yard_to_go -= yard
        self.down += 1
        if yard_to_go <= 0
          firstdown
        elsif down > 4
          self.is_ball_to_home = !is_ball_to_home
          self.ball_on = 100 - ball_on
          firstdown
        end
      end
    end
end
