module MathUtil
  module_function

  def linear_interporation(coord1, coord2, x)
    x1, y1 = coord1
    x2, y2 = coord2
    (y1 + 1.0 * (y2 - y1) / (x2 - x1) * (x - x1))
  end
end
