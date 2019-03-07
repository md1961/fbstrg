class Game < ApplicationRecord
  extend GameEnum
  include GameAttributes

  belongs_to :home_team, class_name: 'Team'
  belongs_to :visitors , class_name: 'Team'
  has_many :plays         , dependent: :destroy
  has_many :game_snapshots, through: :plays
  has_one :schedule

  attr_reader   :result, :previous_spot, :announcement, :goes_into_huddle
  attr_accessor :offensive_play, :offensive_play_set,
                :defensive_play, :defensive_play_set,
                :no_huddle, :error_message

  KICKOFF_YARDLINE = 35
  TOUCHBACK_YARDLINE = 20
  KICKOFF_YARDLINE_AFTER_SAFETY = 20

  def played_over?
    final? && result.blank?
  end

  # TODO: Implement properly offense_human?() and defense_human?()
  def offense_human?
    false
  end
  def defense_human?
    false
  end

  def offense_human_assisted?
    offense.human_assisted?
  end

  def defense_human_assisted?
    defense.human_assisted?
  end

  def choose_offense?
    huddle? && offense_human?
  end

  def choose_defense?
    playing? && defense_human?
  end

  def allows_offensive_play_choice?
    offense_human? || offense_human_assisted?
  end

  def allows_defensive_play_choice?
    defense_human? || defense_human_assisted?
  end

  def hides_offensive_play?
    allows_defensive_play_choice? && offensive_play&.normal? && !result
  end

  def hides_defensive_play?
    allows_offensive_play_choice? && !result
  end

  def shows_offensive_plays_to_choose?
    (huddle? || playing?) && allows_offensive_play_choice?
  end

  def shows_defensive_plays_to_choose?
    playing? && offensive_play&.normal? && allows_defensive_play_choice?
  end

  def clock_runs_out?
    end_of_quarter? || end_of_half? || final?
  end

  def for?(team)
    [home_team_id, visitors_id].include?(team.id)
  end

  def league
    schedule&.league
  end

  def result_and_scores_for(team)
    return [] unless final? && for?(team)
    score_own, score_opp = score_home, score_visitors
    score_own, score_opp = score_opp, score_own if team == visitors
    r = %w[L T W][(score_own <=> score_opp) + 1]
    [r, score_own, score_opp]
  end

  def score_visitors_by_quarter
    scores_by_quarter_for(home_team: false)
  end

  def score_home_by_quarter
    scores_by_quarter_for(home_team: true)
  end

  def prompt
    "#{status}#{no_huddle ? '(no huddle)' : ''}"
  end

  def default_play_input
    return 'choose offense' if choose_offense?
    return 'choose defense' if choose_defense?
    next_play
  end

  def determine_offensive_play(play_input)
    return if timeout_taken?(play_input) || with_no_huddle?(play_input)
    if play_input == '>' && offense_human_assisted?
      @goes_into_huddle = true
      play_input = 'scrimmage'
    end
    @offensive_play_set = nil
    play_input = OffensivePlay.normal_punt.number if play_input.upcase == 'P'
    if offense_human? || OffensivePlay.find_by(number: play_input.to_i)
      play = OffensivePlay.find_by(number: play_input.to_i)
      play = OffensivePlay.normal_kickoff if kickoff? && !play&.kickoff?
      self.error_message = "Illegal offensive play '#{play_input}'" unless play
      if play&.let_clock_run?
        if !clock_stopped && (time_left <= 40 || ([2, 4].include?(quarter) && time_left > 120 && time_left <= 160))
          advance_clock(40, in_play: false)
          save!
          return
        else
          play = nil
          self.error_message = "Cannot let clock run out"
        end
      end
      @offensive_play = play
    elsif !Game.next_plays.keys.include?(play_input)
      self.error_message = "Illegal offensive play '#{play_input}'"
      @offensive_play = nil
    else
      offensive_strategy = offense.offensive_strategy
      @offensive_play, option = offensive_strategy.choose_play(self)
      return if timeout_taken?(option) || with_no_huddle?(option)
      @offensive_play_set = offensive_strategy.play_set
    end
    self.status = :playing if @offensive_play
    save!
    @offensive_play
  end

  def determine_defensive_play
    return if defense_human?
    defensive_strategy = defense.defensive_strategy
    @defensive_play = defensive_strategy.choose_play(self).tap {
      @defensive_play_set = defensive_strategy.play_set
    }
  end

  private

    def timeout_taken?(play_input)
      return false if play_input.blank?
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
      @result = "Timeout ##{3 - timeout_left(is_offense)} by #{is_offense ? 'offense' : 'defense'}"
      return true
    end

    def with_no_huddle?(play_input)
      return false unless play_input&.upcase == 'NH'
      @no_huddle = !@no_huddle unless clock_stopped
      true
    end

    def use_timeout(is_offense)
      is_home = (home_has_ball && is_offense) || (!home_has_ball && !is_offense)
      is_home ? self.timeout_home -= 1 : self.timeout_visitors -= 1
      self.clock_stopped = true
      save!
    end

    def play_result_from_chart
      result_chart = offense.play_result_chart
      result_chart.result(@offensive_play, @defensive_play)
    end

    def get_play(value)
      defensive_play = DefensivePlay.find_by(name: value&.upcase)
      if defense_human? && !defensive_play
        raise Exceptions::IllegalResultStringError, "Illegal defensive play '#{value}'"
      elsif defensive_play
        @defensive_play = defensive_play
        @defensive_play_set = nil
      end
      result = \
        if offensive_play&.normal? && (defense_human? || defense_human_assisted? || value.blank?)
          play_result_from_chart
        elsif value
          unless value.start_with?('=')
            raise Exceptions::IllegalResultStringError, "Specify result string with '=' at head"
          end
          value[1 .. -1]
        end
      Play.parse(result, offensive_play)
    end

  public

  def play(value=nil)
    unless clock_stopped
      time_to_huddle = \
        if last_play_out_of_bounds?
          no_huddle ? rand(2 .. 5) : 30 - rand(0 .. 5)
        else
          (no_huddle ? 10 : 40) - rand(0 .. 5)
        end
      is_two_minute_warning = advance_clock(time_to_huddle, in_play: false)
      return if clock_runs_out? || is_two_minute_warning
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
    if @result.field_goal_try? || @result.extra_point_try?
      try_field_goal(@result)
    else
      yardage_play(@result)
    end
    @announcement = Announcer.announce(@result, self)

    @result.time_to_take = @announcement.total_time_in_sec
    @result.record(self, game_snapshot)

    advance_clock(Clocker.time_to_take(@result, self))
  end

  def advance_to_next_quarter
    self.quarter += 1
    self.time_left = 15 * 60
    self.clock_stopped = true
    self.status = :huddle
    if quarter == 3 || quarter == 5
      self.home_has_ball = !home_kicks_first
      self.ball_on = KICKOFF_YARDLINE
      self.next_play = :kickoff
      self.timeout_home     = 3
      self.timeout_visitors = 3
    end
  end

  def cancel_offensive_play
    return unless playing?
    huddle!
    self.offensive_play = nil
    self.offensive_play_set = nil
  end

  # Hash literal such as '{down: 1, yard_to_go: 10, clock_stopped: false}'.
  RE_TAMPER_GAME = /\A{(:?\w+: (:?\d+|true|false)(?:, )?)+}\z/

  def self.tampering_game?(play_input)
    play_input =~ RE_TAMPER_GAME
  end

  def tamper(value)
    self.error_message = nil
    attrs = value.scan(/(\w+): (\d+|true|false)/).map { |k, v|
      [k, v == 'true' ? true : v == 'false' ? false : v.to_i]
    }.to_h
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
    play_last, play_before = plays.order(number: :desc).first(2)
    snapshot_last   = play_last   .game_snapshot
    snapshot_before = play_before&.game_snapshot
    attrs = snapshot_last.attributes_for_game
    attrs[:status] = :huddle
    if snapshot_before
      attrs[:score_home    ] = snapshot_before.score_home
      attrs[:score_visitors] = snapshot_before.score_visitors
    end
    Game.transaction do
      update!(attrs)
      play_last.destroy
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

  ATTRS_FOR_FINAL_MINUTES = {
    score_home:         23,
    score_visitors:     20,
    timeout_home:        3,
    timeout_visitors:    3,
    quarter:             4,
    time_left:         180,
    clock_stopped:   false,
    home_has_ball:   false,
    ball_on:            50,
    down:                1,
    yard_to_go:         10,
    next_play:  :scrimmage,
    status:        :huddle,
  }

  def to_final_minutes!(attrs = {})
    update!(ATTRS_FOR_FINAL_MINUTES.merge(attrs))
  end

  def to_s(optional_strs = {})
    str_v = optional_strs.find { |k, _| k.downcase.starts_with?('v') }&.last
    str_h = optional_strs.find { |k, _| k.downcase.starts_with?('h') }&.last
    "#{visitors}#{str_v} at #{home_team}#{str_h}"
  end

  private

    def last_play_out_of_bounds?
      plays.order(:number).last&.out_of_bounds?
    end

    def firstdown
      self.down = 1
      self.yard_to_go = 10
    end

    def touchdown
      score(6)
      firstdown
      self.ball_on = 98
      self.next_play = :extra_point
      @result.scoring = :touchdown
    end

    def try_field_goal(play)
      scoring = :no_scoring
      if play.yardage >= 100 - ball_on
        scoring, point = play.field_goal_try? ? [:field_goal, 3] : [:extra_point, 1]
        score(point)
      elsif play.field_goal_try?
        self.ball_on = ball_on - 7
        toggle_possesion
        self.ball_on = TOUCHBACK_YARDLINE if ball_on < TOUCHBACK_YARDLINE
      else
        self.ball_on = KICKOFF_YARDLINE
        self.next_play = :kickoff
      end
      @result.scoring = scoring
    end

    def safety
      score(2, false)
      @result.scoring = :safety
    end

    def score(value, for_offense = true)
      if (home_has_ball && for_offense) || (!home_has_ball && !for_offense)
        self.score_home += value
      else
        self.score_visitors += value
      end
      self.ball_on   = for_offense ? KICKOFF_YARDLINE : KICKOFF_YARDLINE_AFTER_SAFETY
      self.next_play = for_offense ? :kickoff         : :kickoff_after_safety
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
      self.ball_on += play.yardage unless play.incomplete?
      toggle_possesion if play.possession_changing?
      if ball_on >= 100
        play.yardage -= ball_on - 100 unless play.punt_blocked?
        play.save!
        touchdown
      elsif ball_on <= 0
        if play.kick_and_return? || play.intercepted? || play.fumble_rec_by_opponent?
          touchback
        else
          play.yardage += -ball_on unless play.punt_blocked?
          play.save!
          safety
        end
      elsif !play.possession_changing?
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
      self.ball_on = TOUCHBACK_YARDLINE
    end

    def toggle_possesion
      self.home_has_ball = !home_has_ball
      self.ball_on = 100 - ball_on
      firstdown
    end

    def two_minute_warning?(sec_to_advance)
      [2, 4].include?(quarter) && time_left > 120 && time_left - sec_to_advance <= 120
    end

    def advance_clock(sec, in_play: true)
      if two_minute_warning?(sec)
        self.clock_stopped = true
        unless in_play
          self.time_left = 120
          cancel_offensive_play
          @result = "Two minute warning"
          return true
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
      false
    end

    def finish_quarter
      self.clock_stopped = true
      if quarter >= 4 && score_diff != 0
        final!
      elsif quarter == 2
        end_of_half!
      else
        end_of_quarter!
      end
    end

    def scores_by_quarter_for(home_team: true)
      h_scores = h_scores_by_quarter[home_team ? 1 : 0]
      (1 .. quarter).map { |q| h_scores[q] }
    end

    def h_scores_by_quarter
      @scores_by_quarter ||= plays.where("scoring > 0").includes(:game_snapshot).each_with_object(
        [
          Hash.new { |h, k| h[k] = 0 },
          Hash.new { |h, k| h[k] = 0 }
        ]
      ) { |play, hs|
        gss = play.game_snapshot
        team_index = gss.offense == gss.visitors ? 0 : 1
        team_index = 1 - team_index if play.safety? || play.possession_changed?
        hs[team_index][gss.quarter] += play.point_scored
      }
    end
end
