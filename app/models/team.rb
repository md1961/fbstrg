class Team < ActiveRecord::Base
  belongs_to :play_result_chart
  #belongs_to :offensive_play_strategy
  #belongs_to :defensive_play_strategy

  def offensive_play_set
    @offensive_play_set ||= OffensivePlaySet.find_by(name: 'Standard')
  end

  def defensive_play_set
    @defensive_play_set ||= DefensivePlaySet.find_by(name: 'Standard')
  end

  def choose_offensive_play(game)
    if game.kickoff?
      OffensivePlay.kickoff
    elsif game.extra_point?
      OffensivePlay.extra_point
    else
      offensive_play_set.choose(game)
    end
  end
end
