require 'test_helper'

class StrategyToolTest < ActiveSupport::TestCase

  setup do
    @game = games(:one)
  end

  def strategy_tool__kick_FG_now?(game)
    strategy_tool = StrategyTool.new(game)
    strategy_tool.kick_FG_now?
  end

  test '#choose_play' do
    assert !strategy_tool__kick_FG_now?(@game)

    @game.quarter = 2
    @game.ball_on = 50
    @game.time_left = StrategyTool::TIME_LEFT_TO_KICK_FG_NOW + 1
    assert !strategy_tool__kick_FG_now?(@game)

    @game.time_left = StrategyTool::TIME_LEFT_TO_KICK_FG_NOW
    assert strategy_tool__kick_FG_now?(@game)

    @game.ball_on = 49
    assert !strategy_tool__kick_FG_now?(@game)
    @game.ball_on = 50

    @game.quarter = 3
    assert !strategy_tool__kick_FG_now?(@game)

    @game.quarter = 4
    @game.time_left = StrategyTool::TIME_LEFT_TO_KICK_FG_NOW + 1
    assert !strategy_tool__kick_FG_now?(@game)

    @game.time_left = StrategyTool::TIME_LEFT_TO_KICK_FG_NOW
    @game.home_has_ball = true
    @game.score_home     = 3
    @game.score_visitors = 7
    assert !strategy_tool__kick_FG_now?(@game)

    @game.score_visitors = 6
    assert strategy_tool__kick_FG_now?(@game)

    @game.score_visitors = 3
    assert strategy_tool__kick_FG_now?(@game)

    @game.score_visitors = 2
    assert !strategy_tool__kick_FG_now?(@game)

    @game.home_has_ball = false
    @game.score_home     = 7
    @game.score_visitors = 3
    assert !strategy_tool__kick_FG_now?(@game)

    @game.score_home     = 6
    assert strategy_tool__kick_FG_now?(@game)

    @game.score_home     = 3
    assert strategy_tool__kick_FG_now?(@game)

    @game.score_home     = 2
    assert !strategy_tool__kick_FG_now?(@game)
  end
end
