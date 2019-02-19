module Stats

class Run
  attr_reader :attempts, :yards, :long, :touchdowns, :longs

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @yards = 0
    @long = -999
    @touchdowns = 0
    @longs = []
  end

  def tally_from(play)
    if play.on_ground?
      @attempts += 1
      yardage = play.yardage
      @yards += yardage
      @long = yardage if yardage > @long
      @touchdowns += 1 if play.scoring&.starts_with?('TOUCHDOWN')
      @longs << yardage if yardage >= 15
    end
  end

  def yards_per_carry
    yards.to_f / attempts
  end

  def add(other)
    @attempts += other.attempts
    @yards += other.yards
    @long = other.long if other.long > long
    @touchdowns += other.touchdowns
    @longs.concat(other.longs)
  end
end

end
