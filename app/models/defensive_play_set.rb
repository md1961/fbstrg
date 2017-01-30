class DefensivePlaySet < ActiveRecord::Base
  include PlaySetTool

  has_many :defensive_play_set_choices

  def choose
    pick_from(defensive_play_set_choices).defensive_play
  end
end
