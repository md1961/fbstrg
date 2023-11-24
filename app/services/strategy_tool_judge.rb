module StrategyToolJudge
  module_function

  def judgments(game)
    strategy_tool = StrategyTool.new(game)

    StrategyTool.methods_for_judge.map { |name|
      [name, strategy_tool.send(name)] rescue nil
    }.compact.sort_by { |name, _|
      ordering = StrategyTool::NOTABLE_METHODS.index(name) || 999999
      prefix = name.to_s.starts_with?('seconds_') ? 'zzz_' : ''
      [ordering, "#{prefix}#{name}"]
    }
  end
end
