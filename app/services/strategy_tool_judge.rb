module StrategyToolJudge
  extend StrategyTool

  module_function

  def judgments(game)
    StrategyTool.public_instance_methods(false).map { |name|
      [name, StrategyToolJudge.send(name, game)]
    }.sort_by { |name, _|
      ordering = StrategyTool::NOTABLE_METHODS.index(name) || 999999
      prefix = name.to_s.starts_with?('seconds_') ? 'zzz_' : ''
      [ordering, "#{prefix}#{name}"]
    }
  end
end
