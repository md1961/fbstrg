module PlaySetTool

  def pick_from(weight_responders)
    total_weights = weight_responders.map(&:weight).sum
    pick = rand(total_weights)
    weight_responders.inject(0) do |cum_weight, obj_weight|
      cum_weight += obj_weight.weight
      break obj_weight if pick < cum_weight
      cum_weight
    end
  end
end
