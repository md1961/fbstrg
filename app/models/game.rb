class Game < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Team'
  belongs_to :visitors , class_name: 'Team'
  has_many :plays         , dependent: :destroy
  has_many :game_snapshots, dependent: :destroy

  attr_reader   :defensive_play, :result, :offensive_play_set, :defensive_play_set
  attr_accessor :offensive_play, :error_message

  enum next_play: {kickoff: 0, extra_point: 1, scrimmage: 2}

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

  def score_diff
    (score_home - score_visitors) * (home_has_ball ? 1 : -1)
  end

  def final_FG_stands?
    -3 <= score_diff && score_diff <= 0
  end

  def choose_offensive_play
    offensive_strategy = offense.offensive_strategy
    @offensive_play = offensive_strategy.choose_play(self)
    @offensive_play_set = offensive_strategy.play_set
    @offensive_play
  end

  def play_result_from_chart
    @defensive_play = defense.defensive_strategy.choose_play(self)
    result_chart = offense.play_result_chart
    result_chart.result(@offensive_play, @defensive_play)
  end

  def get_plays
    str_results = play_result_from_chart.split('_or_')
    str_results.map { |str_result| Play.parse(str_result) }
  end

  def play(value=nil)
    game_snapshot = GameSnapshot.take_snapshot_of(self)

    value = nil if Game.next_plays.keys.include?(value)
    self.error_message = nil
    # TODO: Shorten withou if ... elsif ...
    if offensive_play.kickoff?
      play = Play.kickoff
    elsif offensive_play.extra_point?
      play = Play.extra_point
    elsif offensive_play.punt?
      play = Play.punt
    elsif offensive_play.field_goal?
      play = Play.field_goal
    elsif value.blank?
      play = get_plays.first
    else
      begin
        play = Play.parse(value)
      rescue Exceptions::IllegalResultStringError => e
        self.error_message = e.message
        return
      end
    end
    @result = play

    self.next_play = :scrimmage
    play.change_due_to(self)
    if play.field_goal? || play.extra_point?
      try_field_goal(play)
    elsif play.possession_changing?
      change_possesion(play.yardage)
    else
      yardage_play(play)
    end
    advance_clock(play.time_to_take)

    play.record(self, game_snapshot)
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
        self.quarter += 1
        if quarter > 4 && score_home != score_visitors
          end_of_game
        elsif quarter == 3
          self.home_has_ball = !home_kicks_first
          self.ball_on = KICKOFF_YARDLINE
          self.next_play = :kickoff
        end
        self.time_left = 15 * 60
      end
    end
end
