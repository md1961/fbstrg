module StrategyToolJudge
  extend StrategyTool

  module_function

  def judgments(game)
    StrategyTool.public_instance_methods(false).map { |name|
      [name, StrategyToolJudge.send(name, game)]
    }.sort_by { |name, _|
      prefix = name.to_s.starts_with?('seconds_') ? 'zzz_' : ''
      "#{prefix}#{name}"
    }
  end
end
