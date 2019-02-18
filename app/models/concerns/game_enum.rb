module GameEnum

  def self.extended(obj)
    obj.enum next_play: {kickoff: 0, extra_point: 1, two_point_conversion: 2, scrimmage: 3, kickoff_after_safety: 4}
    obj.enum status: {huddle: 0, playing: 1, end_of_quarter: 2, end_of_half: 3, final: 4}
  end
end
