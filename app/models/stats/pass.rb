module Stats

class Pass
  attr_reader :attempts, :completions, :yards, :long, :intercepted, :sacked

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @completions = 0
    @yards = 0
    @long = -999
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
    elsif play.incomplete?
      @attempts += 1
    elsif play.intercepted?
      @attempts += 1
      @intercepted += 1
    elsif play.sacked?
      @attempts += 1
      @sacked += 1
    end
  end
end

end
