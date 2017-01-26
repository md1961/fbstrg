class DefensivePlay < ActiveRecord::Base
  has_many :play_results

  def to_s
    formation = [lineman, linebacker, cornerback, safety].join('-')
    "#{name}: #{formation}\n" \
      + "Run: #{against_run}, Pass: #{against_pass}"
  end
end
