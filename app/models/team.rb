class Team < ActiveRecord::Base
  belongs_to :play_result_chart
  belongs_to :offensive_play_strategy
  belongs_to :defensive_play_strategy
end
