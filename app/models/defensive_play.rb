class DefensivePlay < ActiveRecord::Base
  has_many :play_results

  def to_s
    "#{name}: #{[lineman, linebacker, cornerback, safety].join(',')}\nRun: #{against_run}, Pass: #{against_pass}"
  end
end
