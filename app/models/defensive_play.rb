class DefensivePlay < ApplicationRecord
  has_many :play_results

  def formation
    [lineman, linebacker, cornerback, safety].join('-')
  end

  def num_fronts
    lineman.to_i
  end

  def num_LBs
    linebacker.ends_with?('Blz') ? 1 : linebacker.to_i
  end

  def num_DBs
    cornerback.to_i + safety.to_i
  end

  def blitz?
    [linebacker, cornerback, safety].any? { |s| s.ends_with?('Blz') }
  end

  def to_s
    "#{name}: #{formation}\n" \
      + "Run: #{against_run}, Pass: #{against_pass}"
  end
end
