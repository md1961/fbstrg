require 'test_helper'

class OffensiveStrategyTest < ActiveSupport::TestCase

  setup do
    @offensive_strategy = offensive_strategies(:one)
    @game = games(:one)
  end

  def os__kick_FG_now?(game)
    @offensive_strategy.send(:kick_FG_now?, game)
  end

  test '#choose_play' do
    assert !os__kick_FG_now?(@game)

    @game.quarter = 2
    @game.ball_on = 50
    @game.time_left = OffensiveStrategy::TIME_LEFT_TO_KICK_FG_NOW + 1
    assert !os__kick_FG_now?(@game)

    @game.time_left = OffensiveStrategy::TIME_LEFT_TO_KICK_FG_NOW
    assert os__kick_FG_now?(@game)

    @game.ball_on = 49
    assert !os__kick_FG_now?(@game)
    @game.ball_on = 50

    @game.quarter = 3
    assert !os__kick_FG_now?(@game)

    @game.quarter = 4
    @game.time_left = OffensiveStrategy::TIME_LEFT_TO_KICK_FG_NOW + 1
    assert !os__kick_FG_now?(@game)

    @game.time_left = OffensiveStrategy::TIME_LEFT_TO_KICK_FG_NOW
    @game.home_has_ball = true
    @game.score_home     = 3
    @game.score_visitors = 7
    assert !os__kick_FG_now?(@game)

    @game.score_visitors = 6
    assert os__kick_FG_now?(@game)

    @game.score_visitors = 3
    assert os__kick_FG_now?(@game)

    @game.score_visitors = 2
    assert !os__kick_FG_now?(@game)

    @game.home_has_ball = false
    @game.score_home     = 7
    @game.score_visitors = 3
    assert !os__kick_FG_now?(@game)

    @game.score_home     = 6
    assert os__kick_FG_now?(@game)

    @game.score_home     = 3
    assert os__kick_FG_now?(@game)

    @game.score_home     = 2
    assert !os__kick_FG_now?(@game)
  end
end
