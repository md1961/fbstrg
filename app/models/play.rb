class Play < ActiveRecord::Base
  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4, punt: 5, kickoff: 6}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}

  RE_STR_RESULT = /\A([a-zA-Z_]+)?([+-]?(?:\d+|long))?(ob|af)?\z/

  # TODO: Split into methods.
  def self.parse(str)
    m = str.match(RE_STR_RESULT)
    raise Exceptions::IllegalResultStringError, "Illegal result string '#{str}'" unless m
    _result = m[1]
    yardage = m[2]
    remark  = m[3]

    play = new

    case _result
    when nil
      ;
    when 'long'
      yardage = '+long'
    when 'cmp'
      play.result = :complete
    when 'incmp'
      play.result = :incomplete
    when 'int_opp'
      play.result = :intercepted
      yardage = -(yardage.to_i)
    when 'sck'
      play.result = :sacked
    when 'punt', 'kickoff'
      play.result = :"#{_result}"
    when 'fmb'
      play.fumble = :fumble_rec_by_opponent
    when 'pen'
      if yardage.start_with?('-')
        play.penalty = :off_penalty
      else
        play.penalty = :def_penalty
      end
    else
      raise Exceptions::IllegalResultStringError, "Illegal result string '#{str}'"
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

  def self.kickoff
    play = new
    play.result = :kickoff
    return_ends_at = 20 + rand(31) - 10
    play.yardage = 50 - return_ends_at + (50 - 35)
    play
  end

  def out_of_bounds?
    out_of_bounds
  end

  def auto_firstdown?
    auto_firstdown
  end

  def possession_changing?
    kickoff? || intercepted? || fumble_rec_by_opponent?
  end

  private

    def self.long_yardage
      30 + rand(21)
    end
end
