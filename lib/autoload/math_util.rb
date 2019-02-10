module MathUtil
  module_function

  def linear_interporation(coord1, coord2, x)
    x1, y1 = coord1
    x2, y2 = coord2
    (y1 + 1.0 * (y2 - y1) / (x2 - x1) * (x - x1))
  end

  def pick_from_decreasing_distribution(min, max)
    min, max = max, min if min > max
    offset = max - min + 1
    while true
      x = rand(offset) - rand(offset)
      return min + x if x >= 0
    end
  end
end
