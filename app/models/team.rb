class Team < ActiveRecord::Base
  belongs_to :play_result_chart
  belongs_to :offensive_play_strategy
  belongs_to :defensive_play_strategy

  def choose_offensive_play(game)
    if game.kickoff?
      OffensivePlay.kickoff
    elsif game.extra_point?
      OffensivePlay.extra_point
    else
      offensive_play_strategy.choose(game)
    end
  end
end
