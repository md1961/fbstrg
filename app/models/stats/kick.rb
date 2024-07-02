module Stats

class Kick
  attr_reader :attempts, :distances_made, :distances_missed, :distances_blocked,
              :xps_attempted, :xps_made

  def initialize(owner)
    @owner = owner
    @attempts = 0
    @distances_made = []
    @distances_missed = []
    @distances_blocked = []
    @xps_attempted = 0
    @xps_made = 0
  end

  def tally_from(play)
    return unless play.field_goal_try? || play.field_goal_blocked? || play.extra_point_try?
    if play.field_goal_try? || play.field_goal_blocked?
      @attempts += 1
      distance = 100 - play.game_snapshot.ball_on + 10 + Play::YARD_BACK_TO_KICK_FG
      if play.field_goal?
        @distances_made << distance
      else
        @distances_missed << distance
        @distances_blocked << distance if play.field_goal_blocked?
      end
    else
      @xps_attempted += 1
      @xps_made += 1 if play.extra_point?
    end
  end

  def fgs_made
    distances_made.size
  end

  def pct_fg
    fgs_made.to_f / attempts * 100
  end

  def long
    distances_made.max
  end

  def fgs_blocked
    distances_blocked.size
  end

  def attempts_from(range)
    (@distances_made + @distances_missed).find_all { |d| range.include?(d) }.size
  end

  def fgs_made_from(range)
    @distances_made.find_all { |d| range.include?(d) }.size
  end

  def pct_xp
    xps_made.to_f / xps_attempted * 100
  end

  def add(other)
    @attempts += other.attempts
    @distances_made.concat(other.distances_made)
    @distances_missed.concat(other.distances_missed)
    @distances_blocked.concat(other.distances_blocked)
    @xps_attempted += other.xps_attempted
    @xps_made += other.xps_made
  end
end

end
