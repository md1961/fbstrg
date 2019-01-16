class DefensivePlay < ActiveRecord::Base
  has_many :play_results

  def formation
    [lineman, linebacker, cornerback, safety].join('-')
  end

  def to_s
    "#{name}: #{formation}\n" \
      + "Run: #{against_run}, Pass: #{against_pass}"
  end
end
