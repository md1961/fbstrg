class Team < ActiveRecord::Base
  belongs_to :offensive_play_strategy
  belongs_to :defensive_play_strategy
end
