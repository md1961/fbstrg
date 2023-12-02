class DefensivePlay < ApplicationRecord
  has_many :play_results

  def self.pick_from(names)
    return nil if names.blank?

    unless valid_combination?(names)
      raise Exceptions::IllegalResultStringError, "Illegal defensive play '#{names}'"
    end

    names.upcase.split(//).sample.then { |name|
      DefensivePlay.find_by(name: name)
    }
  end

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

  private

    def self.valid_combination?(names)
      names.upcase =~ /\A[A-J]+\z/ \
        && \
      names.upcase.delete('CH').split(//).uniq.map { |c|
        'ABDEFGIJ'.index(c)
      }.minmax.then { |min, max|
        max && min ? max - min : 0
      } <= 3 \
        && \
      names.upcase.delete('ABDEFG').split(//).uniq.sort.join !~ /\A[CH]+[IJ]+\z/
    end
end
