class Play < ApplicationRecord
  belongs_to :game, optional: true
  belongs_to :team, optional: true
  has_one :game_snapshot, dependent: :destroy

  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4,
                 kickoff_and_return: 5, punt_and_return: 6, punt_blocked: 7,
                 field_goal: 8, field_goal_blocked: 9, extra_point: 10}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}

  attr_accessor :scoring, :time_to_take, :air_yardage, :after_safety

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
      elsif offensive_play.kickoff_after_safety?
        punt(after_safety: true)
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
      play.result = :complete
    when 'cmp_fmb'
      play.result = :complete
      play.determine_fumble_recovery
    when 'incmp'
      play.result = :incomplete
    when 'int_opp'
      play.result = :intercepted
      # yardage is gain for defense.  converts it to gain for offense.
      yardage = -(yardage.to_i)
    when 'sck'
      play.result = :sacked
    when 'sck_fmb'
      play.result = :sacked
      play.determine_fumble_recovery
    when 'fmb'
      play.determine_fumble_recovery
    when 'pen'
      play.penalty_yardage = yardage.to_i
      if yardage.start_with?('-')
        play.penalty = :off_penalty
      else
        play.penalty = :def_penalty
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
    new.tap { |play|
      play.result = :kickoff_and_return
    }
  end

  def self.punt(after_safety: false)
    new.tap { |play|
      play.result = :punt_and_return
      play.after_safety = after_safety
    }
  end

  def self.field_goal
    new.tap { |play|
      play.result = :field_goal
      play.yardage = rand(0 .. 100)
    }
  end

  def self.extra_point
    field_goal.tap { |play|
      play.result = :extra_point
    }
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
    self.fumble = rand(100) < pct_rec_by_own ? :fumble_rec_by_own : :fumble_rec_by_opponent
    if yardage - air_yardage >= 10
      min_y = [10, air_yardage].max
      max_y = yardage
      min_y, max_y = max_y, min_x if min_y > max_y
      self.yardage = rand(min_y .. max_y)
    end
  end

  def change_due_to(game)
    if intercepted? && game.ball_on + yardage >= 110
      self.result = :incomplete
      self.yardage = 0
      return
    elsif field_goal?
      length = 100 - game.ball_on + 7 + 10
      pct_blocked = MathUtil.linear_interporation([50, 2.0], [20, 1.0], length)
      if rand * 100 < pct_blocked
        self.result = :field_goal_blocked
        self.fumble = rand(4).zero? ? :fumble_rec_by_own : :fumble_rec_by_opponent
        self.yardage = -7 - rand(10)
      end
      return
    elsif punt_and_return?
      if rand * 100 < 1.0 && !after_safety
        self.result = :punt_blocked
        self.fumble = rand(6).zero? ? :fumble_rec_by_own : :fumble_rec_by_opponent
        self.yardage = -13 - rand(5)
      else
        land_on = game.ball_on + air_yardage
        if land_on >= 100
          self.yardage -= rand(20)
          self.air_yardage = yardage
          land_on = game.ball_on + air_yardage
        end
        if land_on >= 100
          self.yardage = air_yardage
        elsif land_on > rand(90 .. 95)
          self.yardage += (rand(-5 .. 20) * air_yardage / 60.0).to_i
          self.air_yardage = yardage
        end
      end
      return
    elsif kickoff_and_return?
      if rand * 100 < pct_breakaway(game)
        determine_breakaway(game)
      end
      if rand * 100 < pct_fumble(game)
        determine_fumble_recovery
      end
      return
    end

    return if game.offensive_play.nil? || game.defensive_play.nil?

    if complete? || incomplete?
      if rand(0.0 .. 100.0) < self.class.pct_sack(game)
        self.result = :sacked
        self.yardage = -(rand(2 .. 8) + rand(2 .. 7))
      elsif rand(0.0 .. 100.0) < self.class.pct_intercept(game)
        self.result = :intercepted
        op = game.offensive_play
        # TODO: Adjust interception return yardage determination.
        if rand(2).zero?
          self.yardage = air_yardage - (rand(31) - rand(31)).abs
        end
      elsif game.no_huddle && complete?
        self.result = :incomplete if rand(0.0 .. 100.0) < 5.0
      end
    end

    if on_ground? || complete? || intercepted?
      if rand * 100 < pct_breakaway(game)
        determine_breakaway(game)
      elsif (on_ground? || complete?) && game.offensive_play_set&.hurrying? && game.ball_on < 95
        if !game.offensive_play&.hard_to_go_out_of_bounds? && !out_of_bounds
          minus_yardage  = rand(2 .. 7)
          minus_yardage -= rand(0 .. 4) if game.offensive_play.easy_to_go_out_of_bounds?
          self.yardage -= [minus_yardage, 0].max
          self.out_of_bounds = true
        end
      end
    end

    if (on_ground? || complete?) && rand * 100 < pct_fumble(game)
      determine_fumble_recovery
    end
  end

  def determine_air_yardage(offensive_play)
    @air_yardage = \
      if offensive_play.kickoff?
        2.times.map { rand(25 .. 35) }.sum.tap { |air_y|
          self.yardage = air_y - (rand(21) + rand(21))
        }
      elsif offensive_play.punt? || offensive_play.kickoff_after_safety?
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
    self.game_snapshot = game_snapshot
    self.team = game_snapshot.offense
    self.number = game.plays.maximum(:number).to_i + 1
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
      plus = 0.0
      plus = 2.0 if game.no_huddle
      pct_intercept_base(game.offensive_play, game.defensive_play) + plus
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
      plus = 0.0
      plus = 4.0 if game.no_huddle
      pct_sack_base(game.offensive_play, game.defensive_play) + plus
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
      plus = 0.0
      plus = 1.0 if game.no_huddle
      pct_fumble_base(game.offensive_play, game.defensive_play) + plus
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

    def pct_breakaway(game)
      pct_breakaway_base(game.offensive_play, game.defensive_play)
    end

    def pct_breakaway_base(offensive_play, defensive_play)
      if punt_blocked? || field_goal_blocked?
        return 5.0
      elsif intercepted?
        return offensive_play.flair_pass? || offensive_play.sideline_pass? ? 5.0 : 2.0
      elsif kick_and_return?
        return 1.0
      end

      pct = 0.5
      if offensive_play.screen_pass?
        pct += 2.0
      elsif !offensive_play.run?
        pct += 0.1 * offensive_play.max_throw_yard
      end
      pct - defensive_play.num_DBs * 0.05 + (defensive_play.blitz? ? 0.5 : 0.0)
    end

    def determine_breakaway(game)
      if punt_blocked? || field_goal_blocked?
        # TODO: determine_breakaway for punt_blocked and field_goal_blocked.
      elsif intercepted? || kick_and_return?
        self.yardage -= rand(10 .. 120)
      else
        self.yardage += rand(10 .. 100)
        self.yardage = [yardage, rand(20 .. 40)].min if game.defensive_play&.num_DBs >= 7 && rand(3).nonzero?
      end
    end

    def fumble_to_s
      field_goal_blocked? || punt_blocked? ? fumble.sub('fumble_', '') : fumble
    end
end
