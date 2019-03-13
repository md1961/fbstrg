module Stats

class Run
  attr_reader :owner, :attempts, :yards, :long, :touchdowns, :fumbles_lost, :longs

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @yards = 0
    @long = -999
    @touchdowns = 0
    @fumbles_lost = 0
    @longs = []
  end

  def tally_from(play)
    if play.on_ground?
      @attempts += 1
      yardage = play.yardage
      @yards += yardage
      @long = yardage if yardage > @long
      @touchdowns += 1 if play.touchdown?
      @fumbles_lost += 1 if play.fumble_rec_by_opponent?
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
    @fumbles_lost += other.fumbles_lost
    @longs.concat(other.longs)
  end
end

end
