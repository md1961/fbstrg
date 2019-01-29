class Game < ApplicationRecord
  extend GameEnum

  belongs_to :home_team, class_name: 'Team'
  belongs_to :visitors , class_name: 'Team'
  has_many :plays         , dependent: :destroy
  has_many :game_snapshots, dependent: :destroy

  attr_reader   :defensive_play, :result, :defensive_play_set,
                :previous_spot, :announcement
  attr_accessor :offensive_play, :offensive_play_set,
                :no_huddle, :error_message

  KICKOFF_YARDLINE = 35
  TOUCHBACK_YARDLINE = 20
  KICKOFF_YARDLINE_AFTER_SAFETY = 20

  def goal_to_go?
    100 - ball_on <= yard_to_go
  end

  def offense
    home_has_ball ? home_team : visitors
  end

  def defense
    home_has_ball ? visitors : home_team
  end

  # TODO: Implement properly offense_human?() and defense_human?()
  def offense_human?
    false#!home_has_ball
  end
  def defense_human?
    false#!offense_human?
  end

  def choose_offense?
    huddle? && offense_human?
  end

  def choose_defense?
    playing? && defense_human?
  end

  def clock_runs_out?
    end_of_quarter? || end_of_half? || end_of_game?
  end

  def prompt
    "#{status}#{no_huddle ? '(no huddle)' : ''}"
  end

  def default_play_input
    return 'choose offense' if choose_offense?
    return 'choose defense' if choose_defense?
    next_play
  end

  def score_diff
    (score_home - score_visitors) * (home_has_ball ? 1 : -1)
  end

  def final_FG_stands?
    -3 <= score_diff && score_diff <= 0
  end

  def determine_offensive_play(play_input)
    return if timeout_taken?(play_input) || with_no_huddle?(play_input)
    @offensive_play_set = nil
    play_input = OffensivePlay.normal_punt.number if play_input.upcase == 'P'
    if offense_human? || OffensivePlay.find_by(number: play_input.to_i)
      play = OffensivePlay.find_by(number: play_input.to_i)
      play = OffensivePlay.normal_kickoff if kickoff? && !play&.kickoff?
      self.error_message = "Illegal offensive play '#{play_input}'" unless play
      @offensive_play = play
    elsif !Game.next_plays.keys.include?(play_input)
      self.error_message = "Illegal offensive play '#{play_input}'"
      @offensive_play = nil
    else
      offensive_strategy = offense.offensive_strategy
      @offensive_play = offensive_strategy.choose_play(self)
      @offensive_play_set = offensive_strategy.play_set
    end
    self.status = :playing if @offensive_play
    save!
    @offensive_play
  end

  private

    def timeout_taken?(play_input)
      is_offense = \
        case play_input.upcase
        when 'T'
          defense_human? ? offense_human? : true
        when 'TO'
          true
        when 'TD'
          false
        else
          return false
        end
      return false if timeout_left(is_offense).zero?
      use_timeout(is_offense)
      return true
    end

    def with_no_huddle?(play_input)
      return false unless play_input.upcase == 'NH'
      @no_huddle = !@no_huddle unless clock_stopped
      true
    end

    def timeout_left(is_offense)
      is_home = (home_has_ball && is_offense) || (!home_has_ball && !is_offense)
      is_home ? timeout_home : timeout_visitors
    end

    def use_timeout(is_offense)
      is_home = (home_has_ball && is_offense) || (!home_has_ball && !is_offense)
      is_home ? self.timeout_home -= 1 : self.timeout_visitors -= 1
      self.clock_stopped = true
      save!
    end

    def play_result_from_chart(defensive_play = nil)
      if defensive_play
        @defensive_play = defensive_play
        @defensive_play_set = nil
      else
        defensive_strategy = defense.defensive_strategy
        @defensive_play = defensive_strategy.choose_play(self)
        @defensive_play_set = defensive_strategy.play_set
      end
      result_chart = offense.play_result_chart
      result_chart.result(@offensive_play, @defensive_play)
    end

    def get_play(value)
      if defense_human?
        defensive_play = DefensivePlay.find_by(name: value.upcase)
        raise Exceptions::IllegalResultStringError, "Illegal defensive play '#{value}'" unless defensive_play
      end
      result = \
        if offensive_play&.normal? && (defense_human? || value.blank?)
          play_result_from_chart(defensive_play)
        else
          value
        end
      Play.parse(result, offensive_play)
    end

  public

  def play(value=nil)
    unless clock_stopped
      time_to_huddle = (no_huddle ? 10 : 40) - rand(0 .. 5)
      advance_clock(time_to_huddle, in_play: false)
      return if clock_runs_out? || two_minute_warning?
    end

    game_snapshot = GameSnapshot.take_snapshot_of(self)

    value = nil if Game.next_plays.keys.include?(value)
    self.error_message = nil
    begin
      @result = get_play(value)
    rescue Exceptions::IllegalResultStringError => e
      self.error_message = e.message
      return
    end

    @previous_spot = ball_on
    self.next_play = :scrimmage
    self.status = :huddle
    @result.change_due_to(self)
    if @result.field_goal? || @result.extra_point?
      try_field_goal(@result)
    else
      yardage_play(@result)
    end
    @announcement = Announcer.announce(@result, self)
    @result.time_to_take = (@announcement.total_time / 1000.0).ceil - 1
    advance_clock(Clocker.time_to_take(@result, self))

    game_snapshot.update_scores
    @result.record(self, game_snapshot)
  end

  def advance_to_next_quarter
    self.quarter += 1
    self.time_left = 15 * 60
    self.status = :huddle
    if quarter == 3
      self.home_has_ball = !home_kicks_first
      self.ball_on = KICKOFF_YARDLINE
      self.next_play = :kickoff
    end
  end

  def cancel_offensive_play
    return unless playing?
    huddle!
    self.offensive_play = nil
    self.offensive_play_set = nil
  end

  def tamper(value)
    self.error_message = nil
    attrs = value.scan(/(\w+):\s+[+-]?(\d+)/).map { |k, v| [k, v.to_i] }.to_h
    unknown_names = attrs.keys.select { |name| !attributes.include?(name) }
    unless unknown_names.empty?
      self.error_message = "Unknown attribute name: #{unknown_names.join(', ')}"
      return
    end
    is_updated = update(attrs)
    self.error_message = "Failed to update with '#{value}'" unless is_updated
  end

  def revert!
    raise "No GameSnapshot's" if game_snapshots.empty?
    snapshot, snapshot_before = game_snapshots.order(play_id: :desc).first(2)
    attrs = snapshot.attributes_for_game
    attrs[:status] = :huddle
    if snapshot_before
      attrs[:score_home    ] = snapshot_before.score_home
      attrs[:score_visitors] = snapshot_before.score_visitors
    end
    Game.transaction do
      update!(attrs)
      snapshot.play.destroy
      snapshot.destroy
    end
  end

  def restore_from_json(str)
    attrs = JSON.parse(str)
    attrs.delete('id')
    self.home_team = Team.find(attrs.delete('home_team_id'))
    self.visitors  = Team.find(attrs.delete('visitors_id'))
    update(attrs)
    save!
  end

  private

    def firstdown
      self.down = 1
      self.yard_to_go = 10
    end

    def touchdown
      score(6)
      firstdown
      self.ball_on = 98
      self.next_play = :extra_point
      @result.scoring = 'TOUCHDOWN'
    end

    def try_field_goal(play)
      result = 'NO GOOD'
      if play.yardage >= 100 - ball_on
        score(play.field_goal? ? 3 : 1)
        result = 'GOOD'
      elsif play.field_goal?
        toggle_possesion
        self.ball_on = TOUCHBACK_YARDLINE if ball_on < TOUCHBACK_YARDLINE
      else
        self.ball_on = KICKOFF_YARDLINE
        self.next_play = :kickoff
      end
      @result.scoring = result
    end

    def safety
      score(2, false)
      @result.scoring = 'SAFETY'
    end

    def score(value, for_offense = true)
      if (home_has_ball && for_offense) || (!home_has_ball && !for_offense)
        self.score_home += value
      else
        self.score_visitors += value
      end
      self.ball_on = for_offense ? KICKOFF_YARDLINE : KICKOFF_YARDLINE_AFTER_SAFETY
      self.next_play = :kickoff
      finish_quarter if quarter > 4
    end

    def yardage_play(play)
      if play.penalty?
        if ball_on + play.yardage >= 100
          play.yardage = ((100 + ball_on) / 2).to_i - ball_on
        elsif ball_on + play.yardage <= 0
          play.yardage = (ball_on / 2).to_i - ball_on
        end
      end
      self.ball_on += play.yardage
      toggle_possesion if play.possession_changing?
      if ball_on >= 100
        play.yardage -= ball_on - 100
        touchdown
      elsif ball_on <= 0
        if play.intercepted? || kick_and_return?
          touchback
        else
          play.yardage += -ball_on
          safety
        end
      else
        self.yard_to_go -= play.yardage
        self.down += 1 if play.no_penalty?
        if yard_to_go <= 0 || play.auto_firstdown?
          firstdown
        elsif down > 4
          toggle_possesion
        end
      end
    end

    def touchback
      self.ball_on = 100 - TOUCHBACK_YARDLINE
    end

    def toggle_possesion
      self.home_has_ball = !home_has_ball
      self.ball_on = 100 - ball_on
      firstdown
    end

    def two_minute_warning?(sec_to_advance = 0)
      [2, 4].include?(quarter) && time_left >= 120 && time_left - sec_to_advance <= 120
    end

    def advance_clock(sec, in_play: true)
      if two_minute_warning?(sec)
        self.clock_stopped = true
        unless in_play
          self.time_left = 120
          cancel_offensive_play
          return
        end
      end
      self.time_left -= sec
      if time_left <= 0
        self.time_left = 0
        if (extra_point? || two_point_conversion?) && quarter <= 4
          # Another play.
        else
          finish_quarter
        end
      end
    end

    def finish_quarter
      self.clock_stopped = true
      self.offensive_play = nil
      self.offensive_play_set = nil
      if quarter >= 4 && score_diff != 0
        end_of_game!
      elsif quarter == 2
        end_of_half!
      else
        end_of_quarter!
      end
    end
end
