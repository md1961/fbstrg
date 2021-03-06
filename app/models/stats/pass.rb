module Stats

class Pass
  attr_reader :owner, :attempts, :completions, :yards, :long, :touchdowns,
              :intercepted, :sacked, :fumbles_lost, :longs

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @completions = 0
    @yards = 0
    @long = -999
    @touchdowns = 0
    @intercepted = 0
    @sacked = 0
    @fumbles_lost = 0
    @longs = []
  end

  def tally_from(play)
    if play.complete?
      @attempts += 1
      @completions += 1
      yardage = play.yardage
      @yards += yardage
      @long = yardage if yardage > @long
      @touchdowns += 1 if play.touchdown?
      @fumbles_lost += 1 if play.fumble_rec_by_opponent?
      @longs << yardage if yardage >= 20
    elsif play.incomplete?
      @attempts += 1
    elsif play.intercepted?
      @attempts += 1
      @intercepted += 1
    elsif play.sacked?
      @sacked += 1
      @fumbles_lost += 1 if play.fumble_rec_by_opponent?
    end
  end

  def pct_comp
    completions.to_f / attempts * 100
  end

  def yards_per_attempt
    yards.to_f / attempts
  end

  def yards_per_completion
    yards.to_f / completions
  end

  def rating
    return 0.0 if attempts.zero?
    a = (pct_comp / 100 - 0.3) * 5
    b = (yards_per_attempt - 3) * 0.25
    c = (touchdowns.to_f / attempts) * 20
    d = 2.375 - (intercepted.to_f / attempts * 25)
    (a + b + c + d) / 6 * 100
  end

  def add(other)
    @attempts += other.attempts
    @completions += other.completions
    @yards += other.yards
    @long = other.long if other.long > long
    @touchdowns += other.touchdowns
    @intercepted += other.intercepted
    @sacked += other.sacked
    @fumbles_lost += other.fumbles_lost
    @longs.concat(other.longs)
  end
end

end
