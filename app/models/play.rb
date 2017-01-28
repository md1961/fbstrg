class Play < ActiveRecord::Base
  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4,
                 kick_and_return: 5, field_goal: 6, extra_point: 7}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}

  attr_accessor :scoring

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
    when 'fmb'
      play.fumble = :fumble_rec_by_opponent
    when 'pen'
      play.penalty_yardage = yardage.to_i
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
    play.result = :kick_and_return
    return_ends_at = 20 + rand(31) - 10
    play.yardage = 50 - return_ends_at + (50 - 35)
    play
  end

  def self.punt
    play = new
    play.result = :kick_and_return
    play.yardage = 30 + rand(21) - 10
    play
  end

  def self.field_goal
    play = new
    play.result = :field_goal
    percentile = rand(1 .. 100)
    play.yardage = percentile >= 50 ? MathUtil.linear_interporation([95,  2], [50, 33], percentile) \
                                    : MathUtil.linear_interporation([50, 33], [ 0, 60], percentile)
    play
  end

  def self.extra_point
    play = field_goal
    play.result = :extra_point
    play
  end

  def fumble?
    !no_fumble?
  end

  def penalty?
    !no_penalty?
  end

  def out_of_bounds?
    out_of_bounds
  end

  def auto_firstdown?
    auto_firstdown
  end

  def possession_changing?
    kick_and_return? || intercepted? || fumble_rec_by_opponent?
  end

  def time_to_take
    t = if extra_point?
      0
    elsif incomplete? || penalty? || fumble? || field_goal? || kick_and_return?
      15
    elsif intercepted?
      30
    elsif yardage >= 20
      45
    else
      30
    end
    t -= 15 if out_of_bounds?
    [t, 0].max
  end

  def to_s
    a = []
    a << "#{result} #{yardage}y"
    a << fumble unless no_fumble?
    a << 'OB' if out_of_bounds
    a << "#{penalty}#{penalty_yardage} #{auto_firstdown? ? 'AF' : ''}" unless no_penalty?
    a << "(#{time_to_take}sec}"
    a << scoring if scoring.present?
    a.join(' ')
  end

  private

    def self.long_yardage
      30 + rand(21)
    end
end
