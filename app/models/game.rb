class Game < ActiveRecord::Base
  attr_accessor :error_message

  RE_PLAY_VALUE = /\A(?<kind>[a-z]*)(?<yard>-?[0-9]+)/

  def play(value)
    self.error_message = nil
    m = value.match(RE_PLAY_VALUE)
    unless m
      self.error_message = "Illegal play '#{value}'"
      return
    end
    kind = m[:kind]
    yard = Integer(m[:yard])

    self.ball_on += yard
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

  private

    def firstdown
      self.down = 1
      self.yard_to_go = 10
    end
end
