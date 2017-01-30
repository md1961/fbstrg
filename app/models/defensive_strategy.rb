class DefensiveStrategy < ActiveRecord::Base

  def defensive_play_set
    @defensive_play_set ||= DefensivePlaySet.find_by(name: 'Standard')
  end

  def choose_play(game)
    defensive_play_set.choose
  end
end
