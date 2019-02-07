module Stats

class Run
  attr_reader :attempts, :yards, :long

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @yards = 0
    @long = -999
  end

  def tally_from(play)
    if play.on_ground?
      @attempts += 1
      yardage = play.yardage
      @yards += yardage
      @long = yardage if yardage > @long
    end
  end

  def yards_per_carry
    yards.to_f / attempts
  end
end

end
