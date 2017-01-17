class Game < ActiveRecord::Base

  RE_PLAY_VALUE = /\A(?<kind>[a-z]*)(?<yard>-?[0-9]+)/

  def play(value)
    m = value.match(RE_PLAY_VALUE)
    return unless m
    kind = m[:kind]
    yard = Integer(m[:yard])

    self.ball_on += yard
    self.yard_to_go -= yard
    self.down += 1
    if yard_to_go <= 0
      self.down = 1
      self.yard_to_go = 10
    end
  end
end
