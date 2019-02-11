module Stats

class Pass
  attr_reader :attempts, :completions, :yards, :long, :touchdowns, :intercepted, :sacked

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @completions = 0
    @yards = 0
    @long = -999
    @touchdowns = 0
    @intercepted = 0
    @sacked = 0
  end

  def tally_from(play)
    if play.complete?
      @attempts += 1
      @completions += 1
      yardage = play.yardage
      @yards += yardage
      @long = yardage if yardage > @long
      @touchdowns += 1 if play.scoring&.starts_with?('TOUCHDOWN')
    elsif play.incomplete?
      @attempts += 1
    elsif play.intercepted?
      @attempts += 1
      @intercepted += 1
    elsif play.sacked?
      @sacked += 1
    end
  end

  def pct_comp
    completions.to_f / attempts * 100
  end

  def yards_per_attempt
    yards / attempts
  end

  def yards_per_completion
    yards / completions
  end
end

end
