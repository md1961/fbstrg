module StrategyToolJudge
  extend StrategyTool

  module_function

  def judgments(game)
    StrategyTool.public_instance_methods(false).map { |name|
      [name, StrategyToolJudge.send(name, game)]
    }.sort_by(&:first)
  end
end
