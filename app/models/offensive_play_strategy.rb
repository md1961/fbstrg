class OffensivePlayStrategy < ActiveRecord::Base
  has_many :offensive_play_strategy_weights

  def choose
    obj_weights = offensive_play_strategy_weights
    total_weights = obj_weights.map(&:weight).sum
    pick = rand(total_weights)
    obj_weight_picked = obj_weights.inject(0) do |cum_weight, obj_weight|
      cum_weight += obj_weight.weight
      break obj_weight if pick < cum_weight
      cum_weight
    end
    obj_weight_picked.offensive_play
  end
end
