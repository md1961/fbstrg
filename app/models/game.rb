class Game < ActiveRecord::Base

  def play(value)
    if value =~ /\A[-0-9]/
      value = value.to_i
      self.ball_on += value
      self.yard_to_go -= value
      self.down += 1
      if yard_to_go <= 0
        self.down = 1
        self.yard_to_go = 10
      end
    end
  end
end
