module Stats

class Run
  attr_reader :attempts, :yards, :long, :touchdowns

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @yards = 0
    @long = -999
    @touchdowns = 0
  end

  def tally_from(play)
    if play.on_ground?
      @attempts += 1
      yardage = play.yardage
      @yards += yardage
      @long = yardage if yardage > @long
      @touchdowns += 1 if play.scoring&.starts_with?('TOUCHDOWN')
    end
  end

  def yards_per_carry
    yards.to_f / attempts
  end
end

end
