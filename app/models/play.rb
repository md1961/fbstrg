class Play < ApplicationRecord
  belongs_to :game, optional: true
  belongs_to :team, optional: true
  belongs_to :offensive_play    , optional: true
  belongs_to :offensive_play_set, optional: true
  belongs_to :defensive_play    , optional: true
  belongs_to :defensive_play_set, optional: true
  has_one :game_snapshot, dependent: :destroy

  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4,
                 kickoff_and_return: 5, punt_and_return: 6, punt_blocked: 7,
                 field_goal_try: 8, field_goal_blocked: 9, extra_point_try: 10, kneel_down: 11,
                 onside_kick: 12, two_point_try: 13}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}
  enum scoring: {no_scoring: 0, touchdown: 1, field_goal: 2, safety: 3, extra_point: 4, two_point: 5}

  attr_accessor :time_to_take, :after_safety

  def self.parse(str, offensive_play)
    instance = \
      if offensive_play.kneel_down?
        kneel_down
      elsif offensive_play.spike_ball?
        spike_ball
      elsif offensive_play.hail_mary?
        hail_mary
      elsif offensive_play.onside_kickoff?
        onside_kick
      elsif offensive_play.kickoff?
        kickoff
      elsif offensive_play.extra_point?
        extra_point_try
      elsif offensive_play.two_point_conversion?
        two_point_try
      elsif offensive_play.punt?
        punt
      elsif offensive_play.field_goal?
        field_goal_try
      elsif offensive_play.kickoff_after_safety?
        punt(after_safety: true)
      else
        parse_result(str)
      end
    instance.tap { |i|
      i.determine_air_yardage(offensive_play)
    }
  end

  RE_STR_RESULT_REVISED = /\A(\d+%)?([-\d]+)\.\.([-\d]+)(ob)?\z/

  def self.parse_result_revised(str)
    m = str.match(RE_STR_RESULT_REVISED)
    raise Exceptions::IllegalResultStringError, "Illegal result string '#{str}'" unless m
    pct_comp, min_yard, max_yard, remark = m[1 .. 4]
    min_yard, max_yard = min_yard.to_i, max_yard.to_i
    if min_yard > max_yard
      msg = "Illegal result string '#{str}', illegal range (#{min_yard} .. #{max_yard})"
      raise Exceptions::IllegalResultStringError, msg
    end

    play = new.tap { |play|
      play.yardage = rand(min_yard .. max_yard)
      if pct_comp
        play.result = rand * 100 < pct_comp.to_f ? :complete : :incomplete
        play.yardage = 0 if play.incomplete?
      else
        play.result = :on_ground
      end
      play.out_of_bounds = !play.incomplete? && remark == 'ob'
    }
  end

  RE_STR_RESULT = /\A([a-zA-Z_]+)?([+-]?(?:\d+|long))?(ob|af)?\z/

  def self.parse_result(str)
    m = str.match(RE_STR_RESULT)
    unless m
      begin
        return parse_result_revised(str)
      rescue Exceptions::IllegalResultStringError => e
        raise e
      end
    end
    _result, yardage, remark = m[1 .. 3]

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

  def self.kneel_down
    new.tap { |play|
      play.result = :kneel_down
      play.yardage = -2
    }
  end

  def self.spike_ball
    new.tap { |play|
      play.result = :incomplete
    }
  end

  def self.hail_mary
    new.tap { |play|
      play.result = :incomplete
    }
  end

  def self.onside_kick
    new.tap { |play|
      play.result = :onside_kick
    }
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

  def self.field_goal_try
    new.tap { |play|
      play.result = :field_goal_try
      play.yardage = rand(0 .. 100)
    }
  end

  def self.extra_point_try
    field_goal_try.tap { |play|
      play.result = :extra_point_try
    }
  end

  def self.two_point_try
    new.tap { |play|
      play.result = :two_point_try
    }
  end

  def pass?
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
    (kickoff_and_return? || punt_and_return?) && !onside_kick?
  end

  def kick_blocked?
    field_goal_blocked? || punt_blocked?
  end

  def possession_changing?
    (kick_and_return? && !fumble_rec_by_opponent?) || intercepted? \
      || (!kick_and_return? && fumble_rec_by_opponent?) \
      || (kick_blocked? && fumble_rec_by_opponent?)
  end

  def possession_changed?
    possession_changing? \
      || (field_goal_try? && no_scoring?) \
      || (fourth_down_gambled? && yardage < game_snapshot.yard_to_go) \
      || (kick_blocked? && game_snapshot&.down == 4 && yardage < game_snapshot&.yard_to_go) \
  end

  def no_return?
    (kick_and_return? || intercepted?) && yardage == air_yardage
  end

  def blocked_kick_return?
    kick_blocked? && yardage < air_yardage
  end

  def fourth_down_gambled?
    game_snapshot&.down == 4 && (on_ground? || pass? || sacked?)
  end

  def point_scored
    {touchdown: 6, field_goal: 3, safety: 2, extra_point: 1, two_point: 2}[scoring.to_sym]
  end

  def next_play
    return nil unless game
    game.plays.where("number > ?", number).order(:number).first
  end

  def prev_play
    return nil unless game
    game.plays.where("number < ?", number).order(:number).last
  end

  def determine_fumble_recovery(game = nil)
    pct_rec_by_own = \
      if complete?
        33
      elsif sacked?
        67
      else
        50
      end
    self.fumble = rand(100) < pct_rec_by_own ? :fumble_rec_by_own : :fumble_rec_by_opponent
    if game
      if on_ground? || complete?
        min_y = on_ground? ? [-2, yardage].min : air_yardage
        self.yardage = rand(min_y .. yardage) || min_y
        self.fumble = :no_fumble if game.ball_on + yardage >= 100
      elsif kick_and_return?
        return_y = air_yardage - yardage
        return_y = rand(5 .. return_y) if return_y >= 5
        self.yardage = air_yardage - return_y
        if -yardage >= game.ball_on
          self.fumble = :no_fumble  # touchdown
          self.yardage = -game.ball_on
        end
      end
    end
    self.out_of_bounds = false
  end

  def change_due_to(game)
    return if kneel_down? || game.offensive_play&.spike_ball?

    # TODO: Use Play#offensive_play for TeamTraitManager.new().
    @ttm = TeamTraitManager.new(game, game.offensive_play)

    if game.offensive_play.hail_mary?
      pct_comp = 2.0 + @ttm.pass_complete_factor / 5.0
      if rand * 100 < pct_comp
        self.result = :complete
        self.yardage += rand(10) if rand(4).zero?
      elsif rand(4).zero?
        self.result = :intercepted
      end
    elsif field_goal_try?
      self.yardage += @ttm.place_kicking_factor * rand(4) if yardage >= 20
      length = 100 - game.ball_on + 7 + 10
      pct_blocked = MathUtil.linear_interporation([50, 2.0], [20, 1.0], length)
      if rand * 100 < pct_blocked
        self.result = :field_goal_blocked
        self.air_yardage = -7 - rand(10)
        self.yardage = air_yardage
        self.fumble = rand(2).zero? ? :fumble_rec_by_own : :fumble_rec_by_opponent
        if fumble_rec_by_opponent? && rand(5).zero?
          self.yardage -= rand(10 .. 150)
        end
      end
      return
    elsif punt_and_return?
      yards_back = yards_back_for_punt(game)
      yards_back_reduced = NORMAL_YARDS_BACK_FOR_PUNT - yards_back
      if yards_back_reduced > 0
        yards_reduced = yards_back_reduced * rand(1 .. 3)
        self.air_yardage -= yards_reduced
        self.yardage -= yards_reduced
      end
      pct_blocked = 1.0 + yards_back_reduced * 0.2
      if rand * 100 < pct_blocked && !after_safety
        self.result = :punt_blocked
        self.air_yardage = -yards_back - rand(-2 .. 5)
        self.yardage = air_yardage
        lands_on = game.ball_on + air_yardage
        self.fumble = lands_on <= -10 || rand(3).zero? ? :fumble_rec_by_own : :fumble_rec_by_opponent
        if fumble_rec_by_opponent? && lands_on > 0 && rand(5).zero?
          self.yardage -= rand(10 .. 100)
        end
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
      self.yardage = air_yardage if take_touchback_on_kickoff?(game)
      if rand * 100 < pct_breakaway(game)
        determine_breakaway(game)
      end
      return_y = air_yardage - yardage
      if return_y >= 5 && rand * 100 < pct_fumble(game)
        determine_fumble_recovery(game)
      end
      return
    end

    return if game.offensive_play.nil? || game.defensive_play.nil?

    if complete? || incomplete?
      change_pass_by_team_traits(game)
      if rand * 100 < pct_sack(game)
        self.result = :sacked
        self.yardage = -[(rand(2 .. 8) + rand(2 .. 7)), game.ball_on + 8].min
        self.out_of_bounds = false
        if rand(5).zero?
          determine_fumble_recovery
        end
      elsif rand * 100 < pct_intercept(game)
        self.result = :intercepted
        # TODO: Adjust interception return yardage determination according to offensive_play.
        self.yardage = air_yardage
        self.out_of_bounds = false
        no_need_to_return = game.quarter == 4 && game.score_diff < 0 && game.timeout_left <= 20
        self.yardage -= (rand(31) - rand(31)).abs if rand(2).zero? && !no_need_to_return
      elsif game.no_huddle && complete?
        if rand * 100 < 5.0 - @ttm.qb_read_factor * 0.5
          self.result = :incomplete
          self.yardage = 0
          self.out_of_bounds = false
        end
      end
    end

    if intercepted?
      return_from = game.ball_on + air_yardage
      if return_from >= 110
        self.result = :incomplete
        self.yardage = 0
        self.out_of_bounds = false
        return
      elsif game.two_point_try
        self.yardage = air_yardage
        return
      elsif return_from >= 100
        depth = return_from - 100
        if game.score_diff <= 0 || return_from >= 105 || rand(depth + 1) > 0
          self.yardage = air_yardage
          return
        end
      end
    end

    change_run_yardage_by_team_traits(game) if on_ground?

    if on_ground? || complete? || intercepted? || kickoff_and_return?
      if rand * 100 < pct_breakaway(game)
        determine_breakaway(game)
      end
      if tries_to_go_out_of_bounds?(game)
        if rand(2).zero?
        minus_yardage  = rand(2 .. 6)
        minus_yardage -= rand(1 .. 4) if game.offensive_play.easy_to_go_out_of_bounds?
        self.yardage -= [minus_yardage, 0].max
        self.out_of_bounds = true
        end
      end
    end

    if (on_ground? || complete?) && rand * 100 < pct_fumble(game)
      determine_fumble_recovery(game)
    end
  end

  def take_touchback_on_kickoff?(game)
    land_on = game.ball_on + air_yardage
    return false if land_on < 100
    return true if land_on >= 110
    return true if game.score_diff < 0  # Receiving team is winning.
    return true if game.quarter != 4
    return true if land_on > 105
    return false if game.score_diff > 14
    return true if land_on > 102
    game.score_diff > 7
  end

  def determine_air_yardage(offensive_play)
    self.air_yardage = \
      if offensive_play.hail_mary?
        rand(offensive_play.throw_yard_range).tap { |air_y|
          self.yardage = air_y
        }
      elsif onside_kick?
        self.yardage = rand(8 .. 15)
        self.fumble = rand(100) < 15 ? :fumble_rec_by_own : :fumble_rec_by_opponent
        yardage
      elsif offensive_play.kickoff?
        2.times.map { rand(25 .. 35) }.sum.tap { |air_y|
          self.yardage = air_y - (10 + rand(11) + rand(11))
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
    self.offensive_play     = game.offensive_play
    self.offensive_play_set = game.offensive_play_set
    self.defensive_play     = game.defensive_play
    self.defensive_play_set = game.defensive_play_set
    self.game_snapshot = game_snapshot
    self.team = game_snapshot.offense
    self.number = game.plays.maximum(:number).to_i + 1
    save!
  end

  def to_s
    a = []
    if tn = timeout_team_and_number
      a << "(#{tn[0]} TO ##{tn[1]})"
    end
    a << result_to_s
    a << fumble_to_s unless no_fumble? || onside_kick?
    a << 'OB' if out_of_bounds && no_scoring?
    a << "#{penalty}#{penalty_yardage} #{auto_firstdown? ? 'AF' : ''}" unless no_penalty?
    a << "(#{time_to_take}sec)" if time_to_take
    a << "(GAMBLE)" if fourth_down_gambled?
    if !no_scoring? && !extra_point?
      a << scoring.upcase.gsub('_', ' ')
      a << "(XP #{next_play.no_scoring? ? 'NO ': ''}GOOD)" if touchdown? && next_play
    end
    a.join(' ')
  end

  def return_yardage
    [air_yardage - yardage, game_snapshot.ball_on + air_yardage].min
  end

  private

    def self.long_yardage
      30 + rand(21)
    end

    def tries_to_go_out_of_bounds?(game)
      return false unless on_ground? || complete?
      return false unless game.offense_hurrying?
      return false if out_of_bounds
      return false if game.offensive_play&.hard_to_go_out_of_bounds?
      return false if game.down == 4
      return false if game.ball_on >= 95
      return false if game.ball_on + air_yardage >= 100
      true
    end

    NORMAL_YARDS_BACK_FOR_PUNT = 13

    def yards_back_for_punt(game)
      [NORMAL_YARDS_BACK_FOR_PUNT, game.ball_on + 8].min
    end

    # TODO: Consider to alter pass-related pct_...() back on own goal line.

    def pct_intercept(game)
      plus = 0.0
      plus += 2.0 if game.offensive_play.confusing?
      plus += 2.0 - @ttm.qb_read_factor * 0.2 if game.no_huddle
      base = self.class.pct_intercept_base(game.offensive_play, game.defensive_play)
      (base + plus) * @ttm.pass_interception_factor
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

    def pct_sack(game)
      plus = 0.0
      plus += 4.0 - @ttm.qb_read_factor * 0.4 if game.no_huddle
      plus += 4.0 if game.offensive_play.confusing?
      plus -= @ttm.pass_protect_factor
      [self.class.pct_sack_base(game.offensive_play, game.defensive_play) + plus, 0.1].max
    end

    def self.pct_sack_base(offensive_play, defensive_play)
      if offensive_play.screen_pass?
        return defensive_play.blitz? ? 0.0 : 0.1
      end
      max_throw_yard = offensive_play.max_throw_yard
      num_linemen = defensive_play.lineman.to_i
      pct = max_throw_yard / 10.0 * 2
      pct += 4 if defensive_play.blitz?
      pct += 2 if num_linemen >= 4
      pct
    end

    def pct_fumble(game)
      plus = 0.0
      plus += 1.0 if game.no_huddle
      plus += 2.0 if game.offensive_play.confusing?
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
      pct = pct_breakaway_base(game.offensive_play, game.defensive_play)

      if on_ground?
        pct_add = @ttm.run_breakaway_factor * 0.1
        [pct + pct_add, 0.1].max
      elsif complete?
        pct_add = @ttm.pass_breakaway_factor * 0.5
        [pct + pct_add, 1.0].max
      elsif kick_and_return?
        pct_add = @ttm.return_breakaway_factor * 0.1
        [pct + pct_add, 0.1].max
      else
        pct
      end
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
        pct += 1.0
      elsif !offensive_play.run?
        pct += 0.1 * offensive_play.max_throw_yard
        pct += 0.3 if offensive_play.crossing_pass?
      end
      pct - defensive_play.num_DBs * 0.05 + (defensive_play.blitz? ? 0.5 : 0.0)
    end

    def determine_breakaway(game)
      if intercepted? || kick_and_return? || kick_blocked?
        self.yardage -= rand(10 .. 120)
      else
        self.yardage += rand(10 .. 100)
        self.yardage = [yardage, rand(20 .. 40)].min if game.defensive_play&.num_DBs >= 7 && rand(3).nonzero?
      end
    end

    # TODO: Take offensive_play and defensive_play into account for change_run_yardage_by_team_traits().
    def change_run_yardage_by_team_traits(game)
      factor = @ttm.run_yardage_factor * 2 + 1  # 1 .. 41
      self.yardage += MathUtil.pick_from_decreasing_distribution( 1,  5) if rand * 100 < factor
      self.yardage += MathUtil.pick_from_decreasing_distribution(10, 20) if rand * 100 < factor / 10.0
    end

    def change_pass_by_team_traits(game)
      if incomplete? && rand * 100 < @ttm.pass_complete_factor
        self.result = :complete
        self.yardage = air_yardage
      end
      if complete?
        fluctuation_factor = rand(-2 .. 2)
        gain_factor = @ttm.pass_yardage_factor + fluctuation_factor
        self.yardage += (yardage * (gain_factor / 10.0) * rand).round
        self.air_yardage = yardage if yardage < air_yardage
      end
    end

    def timeout_team_and_number
      return nil unless prev_play
      gss_curr = game_snapshot
      gss_prev = prev_play.game_snapshot
      timeout_home_curr = gss_curr.timeout_home
      timeout_visi_curr = gss_curr.timeout_visitors
      timeout_home_prev = gss_prev.timeout_home
      timeout_visi_prev = gss_prev.timeout_visitors
      return nil if timeout_home_curr + timeout_visi_curr >= timeout_home_prev + timeout_visi_prev
      team, timeout_left = timeout_home_curr < timeout_home_prev ? [gss_curr.home_team, timeout_home_curr] \
                                                                 : [gss_curr.visitors , timeout_visi_curr]
      [team.abbr, 3 - timeout_left]
    end

    def fumble_to_s
      s = fumble.gsub('_', ' ')
      return s unless kick_blocked?
      s.sub!('fumble ', '')
      if yardage == air_yardage
        "#{-yardage} yard loss #{s}"
      else
        "#{return_yardage} yard return"
      end
    end

    def result_to_s
      if onside_kick?
        team = fumble_rec_by_own? ? 'kicking' : 'receiving'
        "Onside kickoff #{yardage} yard, recovered by #{team} team"
      elsif kick_and_return? || intercepted?
        kick, int = '', ''
        kick = kickoff_and_return? ? ' kickoff' : ' punt' if kick_and_return?
        int = 'Intercepted ' if intercepted?
        return_y = "#{return_yardage.zero? ? 'no' : "#{return_yardage } yard"} return"
        "#{int}#{air_yardage} yard#{kick}, #{return_y}"
      elsif on_ground?
        "Run " + (yardage.zero? ? "no gain" : yardage > 0 ? "#{yardage} yard" : "#{-yardage} yard loss")
      elsif complete?
        run_after = yardage - air_yardage
        sup = yardage < 0 ? ' loss' : run_after > 0 ? " (#{air_yardage}y air + #{run_after}y run_after)" : ''
        "Pass #{yardage.abs} yard#{sup}"
      elsif incomplete?
        "Incomplete"
      elsif sacked?
        "QB sacked #{-yardage} yard loss"
      elsif field_goal_try?
        "#{100 - game_snapshot.ball_on + 10 + 7} yard" + (no_scoring? ? " field goal NO GOOD" : "")
      elsif extra_point_try?
        "Extra point is #{extra_point? ? '' : 'no '}good"
      elsif kick_blocked?
        "Blocked #{field_goal_blocked? ? 'field goal' : 'punt'}"
      elsif kneel_down?
        "QB kneel down"
      else
        "#{result} #{yardage} yard"
      end
    end
end
