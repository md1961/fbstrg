class Play < ActiveRecord::Base
  belongs_to :game
  belongs_to :team
  has_one :game_snapshot

  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4,
                 kickoff_and_return: 5, punt_and_return: 6, punt_blocked: 7,
                 field_goal: 8, field_goal_blocked: 9, extra_point: 10}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}

  attr_accessor :scoring, :time_to_take

  RE_STR_RESULT = /\A([a-zA-Z_]+)?([+-]?(?:\d+|long))?(ob|af)?\z/

  # TODO: Split into methods.
  def self.parse(str)
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
    when 'incmp'
      play.incomplete!
    when 'int_opp'
      play.intercepted!
      # yardage is gain for defense.  converts it to gain for offense.
      yardage = -(yardage.to_i)
    when 'sck'
      play.sacked!
    when 'fmb'
      play.fumble = rand(2).zero? ? :fumble_rec_by_own : :fumble_rec_by_opponent
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
    return_ends_at = 20 + rand(31) - 10
    play.yardage = 50 - return_ends_at + (50 - 35)
    play
  end

  def self.punt
    play = new
    play.punt_and_return!
    play.yardage = 30 + rand(21) - 10
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

  def change_due_to(game)
    if intercepted? && game.ball_on + yardage >= 110
      self.incomplete!
      self.yardage = 0
    elsif field_goal?
      length = 100 - game.ball_on + 7 + 10
      pct_blocked = MathUtil.linear_interporation([50, 2.0], [20, 1.0], length)
      if rand(100) < pct_blocked
        field_goal_blocked!
        rand(4).zero? ? fumble_rec_by_own! : fumble_rec_by_opponent!
        self.yardage = -7 - rand(10)
      end
    elsif punt?
      if false
        punt_blocked!
        rand(6).zero? ? fumble_rec_by_own! : fumble_rec_by_opponent!
        self.yardage = -13 - rand(5)
      end
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

    def fumble_to_s
      field_goal_blocked? || punt_blocked? ? fumble.sub('fumble_', '') : fumble
    end
end
