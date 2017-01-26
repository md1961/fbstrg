class Play < ActiveRecord::Base
  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}

  # ["#", "#ob", "cmp#", "cmp#ob", "cmp+long", "fmb", "incmp", "int_opp#", "long", "pen#", "pen#af", "sck#", "sck#ob"]
  RE_STR_RESULT = /\A([a-zA-Z_]+)?([+-]?(?:\d+|long))?(ob|af)?\z/
  def self.parse(str)
    m = str.match(RE_STR_RESULT)
    # TODO: Define an exception.
    raise StandardError, "Illegal string result '#{str}'" unless m
    _result = m[1]
    yardage = m[2]
    remark  = m[3]

    play = new

    case _result
    when 'long'
      yardage = '+long'
    when 'cmp'
      play.result = :complete
    when 'incmp'
      play.result = :incomplete
    when 'int_opp'
      play.result = :intercepted
    when 'sck'
      play.result = :sacked
    when 'fmb'
      play.fumble = :fumble_rec_by_opponent
    when 'pen'
      if yardage.start_with?('-')
        play.penalty = :off_penalty
      else
        play.penalty = :def_penalty
      end
    end

    case remark
    when 'ob'
      play.out_of_bounds = true
    when 'af'
      play.auto_firstdown = true
    end

    play.yardage = yardage.try(:end_with?, 'long') ? long_yardage : Integer(yardage || 0)
    play
  end

  private

    def self.long_yardage
      30 + rand(21)
    end
end
