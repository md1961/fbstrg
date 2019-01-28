class Play < ApplicationRecord
  belongs_to :game, optional: true
  belongs_to :team, optional: true
  has_one :game_snapshot

  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4,
                 kickoff_and_return: 5, punt_and_return: 6, punt_blocked: 7,
                 field_goal: 8, field_goal_blocked: 9, extra_point: 10}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}

  attr_accessor :scoring, :time_to_take, :air_yardage

  RE_STR_RESULT = /\A([a-zA-Z_]+)?([+-]?(?:\d+|long))?(ob|af)?\z/

  def self.parse(str, offensive_play)
    instance = \
      if offensive_play.kickoff?
        kickoff
      elsif offensive_play.extra_point?
        extra_point
      elsif offensive_play.punt?
        punt
      elsif offensive_play.field_goal?
        field_goal
      else
        parse_result(str, offensive_play)
      end
    instance.tap { |i|
      i.determine_air_yardage(offensive_play)
    }
  end

  # TODO: Split into methods.
  def self.parse_result(str, offensive_play)
    m = str.match(RE_STR_RESULT)
    raise Exceptions::IllegalResultStringError, "Illegal result string '#{str}'" unless m
    _result = m[1]
    yardage = m[2]
    remark  = m[3]

    play = new

    case _result&.downcase
    when nil
      ;
    when 'long'
      yardage = '+long'
    when 'cmp'
      play.complete!
    when 'cmp_fmb'
      play.complete!
      play.determine_fumble_recovery
    when 'incmp'
      play.incomplete!
    when 'int_opp'
      play.intercepted!
      # yardage is gain for defense.  converts it to gain for offense.
      yardage = -(yardage.to_i)
    when 'sck'
      play.sacked!
    when 'sck_fmb'
      play.sacked!
      play.determine_fumble_recovery
    when 'fmb'
      play.determine_fumble_recovery
    when 'pen'
      play.penalty_yardage = yardage.to_i
      if yardage.start_with?('-')
        play.off_penalty!
      else
        play.def_penalty!
        play.auto_firstdown = true if play.penalty_yardage >= 15
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
    play.kickoff_and_return!
    play
  end

  def self.punt
    play = new
    play.punt_and_return!
    play
  end

  def self.field_goal
    play = new
    play.field_goal!
    percentile = rand(1 .. 100)
    play.yardage = percentile >= 50 ? MathUtil.linear_interporation([95,  2], [50, 33], percentile).round \
                                    : MathUtil.linear_interporation([50, 33], [ 0, 60], percentile).round
    play
  end

  def self.extra_point
    play = field_goal
    play.extra_point!
    play
  end

  def throw?
    complete? || incomplete? || intercepted?
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

  def kick_and_return?
    kickoff_and_return? || punt_and_return?
  end

  def possession_changing?
    kick_and_return? || intercepted? || fumble_rec_by_opponent?
  end

  def fair_catch?
    punt_and_return? && yardage == air_yardage
  end

  def determine_fumble_recovery
    pct_rec_by_own = \
      if complete?
        33
      elsif sacked?
        67
      else
        50
      end
    rand(100) < pct_rec_by_own ? fumble_rec_by_own! : fumble_rec_by_opponent!
  end

  # TODO: Change for coffin-corner, roll-into-zone for punt.
  def change_due_to(game)
    return if game.offensive_play.nil? || game.defensive_play.nil?

    if complete? || incomplete?
      if rand(0.0 .. 100.0) < self.class.pct_sack(game)
        sacked!
        self.yardage = -(rand(2 .. 8) + rand(2 .. 7))
      elsif rand(0.0 .. 100.0) < self.class.pct_intercept(game)
        intercepted!
        op = game.offensive_play
        self.yardage = rand(op.min_throw_yard .. op.max_throw_yard)
        # TODO: Adjust interception return yardage determination.
        if rand(2).zero?
          self.yardage -= rand(21) + rand(21)
        end
      end
    end

    if intercepted? && game.ball_on + yardage >= 110
      self.incomplete!
      self.yardage = 0
    elsif field_goal?
      length = 100 - game.ball_on + 7 + 10
      pct_blocked = MathUtil.linear_interporation([50, 2.0], [20, 1.0], length)
      if rand * 100 < pct_blocked
        field_goal_blocked!
        rand(4).zero? ? fumble_rec_by_own! : fumble_rec_by_opponent!
        self.yardage = -7 - rand(10)
      end
    elsif punt_and_return?
      if rand * 100 < 1.0
        punt_blocked!
        rand(6).zero? ? fumble_rec_by_own! : fumble_rec_by_opponent!
        self.yardage = -13 - rand(5)
      end
    end

    if rand * 100 < pct_fumble(game)
      determine_fumble_recovery
      # TODO: Reduce yardage for fumble on the way.
    end
  end

  def determine_air_yardage(offensive_play)
    @air_yardage = \
      if offensive_play.kickoff?
        2.times.map { rand(25 .. 35) }.sum.tap { |air_y|
          self.yardage = air_y - (rand(21) + rand(21))
        }
      elsif offensive_play.punt?
        3.times.map { rand(10 .. 20) }.sum.tap { |air_y|
          pct_returnable = MathUtil.linear_interporation([30, 10.0], [60, 60.0], air_y)
          is_returnable = rand * 100 < pct_returnable
          # TODO: Adjust punt return yardage determination.
          self.yardage = air_y - (is_returnable ? rand(10) + rand(10) : 0)
        }
      elsif !offensive_play.min_throw_yard
        0
      else
        min = offensive_play.min_throw_yard
        max = offensive_play.max_throw_yard
        min = [min, yardage].max if intercepted?
        max = [max, yardage].min if complete?
        min = max if max < min
        rand(min .. max)
      end
  end

  def record(game, game_snapshot)
    self.game = game
    self.team = game_snapshot.offense
    self.number = game.plays.maximum(:number).to_i + 1
    self.game_snapshot = game_snapshot
    save!
  end

  def to_s
    a = []
    a << "#{result} #{yardage} yard"
    a << fumble_to_s unless no_fumble?
    a << 'OB' if out_of_bounds
    a << "#{penalty}#{penalty_yardage} #{auto_firstdown? ? 'AF' : ''}" unless no_penalty?
    a << "(#{time_to_take || '? '}sec)"
    a << scoring if scoring.present?
    a.join(' ')
  end

  private

    def self.long_yardage
      30 + rand(21)
    end

    def self.pct_intercept(game)
      pct_intercept_base(game.offensive_play, game.defensive_play)
    end

    def self.pct_intercept_base(offensive_play, defensive_play)
      if offensive_play.screen_pass?
        return defensive_play.blitz? ? 0.0 : 0.1 * defensive_play.num_fronts
      end
      divisor = offensive_play.flair_pass? || offensive_play.sideline_pass? ? 2 : 1
      num_defenders_for_pass(offensive_play, defensive_play) * 1.0 / divisor
    end

    def self.num_defenders_for_pass(offensive_play, defensive_play)
      max_throw_yard = offensive_play.max_throw_yard
      num_LBs = defensive_play.num_LBs
      num_DBs = defensive_play.num_DBs
      num_defenders = max_throw_yard >= 20 ? num_DBs : num_LBs
    end

    def self.pct_sack(game)
      pct_sack_base(game.offensive_play, game.defensive_play)
    end

    def self.pct_sack_base(offensive_play, defensive_play)
      if offensive_play.screen_pass?
        return defensive_play.blitz? ? 0.0 : 0.1
      end
      max_throw_yard = offensive_play.max_throw_yard
      num_linemen = defensive_play.lineman.to_i
      pct = max_throw_yard / 10.0 * 2
      pct += 5 if defensive_play.blitz?
      pct += 2 if num_linemen >= 4
      pct
    end

    def pct_fumble(game)
      pct_fumble_base(game.offensive_play, game.defensive_play)
    end

    def pct_fumble_base(offensive_play, defensive_play)
      if on_ground?
        1.0 + defensive_play.num_fronts * 0.2
      elsif complete?
        num_defenders = self.class.num_defenders_for_pass(offensive_play, defensive_play)
        0.5 + num_defenders * 0.1
      elsif sacked?
        3.0 + (defensive_play.blitz? ? 3.0 : 0)
      elsif kickoff_and_return?
        2.0
      elsif punt_and_return?
        1.0
      else
        0.0
      end
    end

    def fumble_to_s
      field_goal_blocked? || punt_blocked? ? fumble.sub('fumble_', '') : fumble
    end
end
