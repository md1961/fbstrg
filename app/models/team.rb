class Team < ApplicationRecord
  belongs_to :play_result_chart
  belongs_to :offensive_strategy
  belongs_to :defensive_strategy

  def to_s
    name
  end
end
