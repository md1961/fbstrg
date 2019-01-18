class Game < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Team'
  belongs_to :visitors , class_name: 'Team'
  has_many :plays         , dependent: :destroy
  has_many :game_snapshots, dependent: :destroy

  attr_reader   :defensive_play, :result, :offensive_play_set, :defensive_play_set,
                :previous_spot, :announcement
  attr_accessor :offensive_play, :error_message

  enum next_play: {kickoff: 0, extra_point: 1, two_point_conversion: 2, scrimmage: 3}
  enum status: {huddle: 0, playing: 1, end_of_quarter: 2, end_of_half: 3, end_of_game: 4}

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

  def prompt
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
    if offense_human?
      play_input = OffensivePlay.normal_punt.number if play_input.upcase == 'P'
      play = OffensivePlay.find_by(number: play_input.to_i)
      play = OffensivePlay.normal_kickoff if kickoff? && !play&.kickoff?
      self.error_message = "Illegal offensive play '#{play_input}'" unless play
      @offensive_play = play
      @offensive_play_set = nil
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

    def get_plays(defensive_play = nil)
      str_results = play_result_from_chart(defensive_play).split('_or_')
      str_results.map { |str_result| Play.parse(str_result) }
    end

    def get_play(value)
      # TODO: Shorten withou if ... elsif ...
      if offensive_play.kickoff?
        Play.kickoff
      elsif offensive_play.extra_point?
        Play.extra_point
      elsif offensive_play.punt?
        Play.punt
      elsif offensive_play.field_goal?
        Play.field_goal
      elsif value.blank?
        get_plays.first
      elsif defense_human?
        defensive_play = DefensivePlay.find_by(name: value.upcase)
        raise Exceptions::IllegalResultStringError, "Illegal defensive play '#{value}'" unless defensive_play
        get_plays(defensive_play).first
      else
        Play.parse(value)
      end
    end

  public

  def play(value=nil)
    game_snapshot = GameSnapshot.take_snapshot_of(self)

    value = nil if Game.next_plays.keys.include?(value)
    self.error_message = nil
    begin
      @result = get_play(value)
    rescue Exceptions::IllegalResultStringError => e
      self.error_message = e.message
      return
    end

    self.next_play = :scrimmage
    self.status = :huddle
    @result.change_due_to(self)
    if @result.field_goal? || @result.extra_point?
      try_field_goal(@result)
    elsif @result.possession_changing?
      change_possesion(@result.yardage)
    else
      yardage_play(@result)
    end
    advance_clock(@result.time_to_take)

    @announcement = Announcer.announce(@result, self)

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
      self.status = :end_of_game if quarter > 4
    end

    def yardage_play(play)
      if play.penalty?
        if ball_on + play.yardage >= 100
          play.yardage = ((100 + ball_on) / 2).to_i - ball_on
        elsif ball_on + play.yardage <= 0
          play.yardage = (ball_on / 2).to_i - ball_on
        end
      end
      @previous_spot = ball_on
      self.ball_on += play.yardage
      if ball_on >= 100
        play.yardage -= ball_on - 100
        touchdown
      elsif ball_on <= 0
        safety
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

    def change_possesion(yard)
      self.ball_on += yard
      touchback if ball_on >= 100
      toggle_possesion
    end

    def touchback
      self.ball_on = 100 - TOUCHBACK_YARDLINE
    end

    def toggle_possesion
      self.home_has_ball = !home_has_ball
      self.ball_on = 100 - ball_on
      firstdown
    end

    def advance_clock(sec)
      self.time_left -= sec
      if time_left <= 0
        self.time_left = 0
        if (extra_point? || two_point_conversion?) && quarter <= 4
          # Another play.
        elsif quarter >= 4 && score_home != score_visitors
          self.status = :end_of_game
        elsif quarter == 2
          self.status = :end_of_half
        else
          self.status = :end_of_quarter
        end
      end
    end
end
