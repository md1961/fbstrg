class PlayResult < ActiveRecord::Base
  belongs_to :play_result_chart
  belongs_to :offensive_play
  belongs_to :defensive_play
end
