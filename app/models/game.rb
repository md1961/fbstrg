class Game < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Team'
  belongs_to :visitors , class_name: 'Team'

  attr_reader :offensive_play, :defensive_play, :result
  attr_accessor :error_message

  enum next_play: {kickoff: 0, extra_point: 1, scrimmage: 2}

  KICKOFF_YARDLINE = 35
  TOUCHBACK_YARDLINE = 20

  RE_PLAY_VALUE = /\A(?<kind>[a-z]*)(?<yard>-?[0-9]+)/

  def offense
    is_ball_to_home ? home_team : visitors
  end

  def defense
    is_ball_to_home ? visitors : home_team
  end

  # TODO: Add score_offense() and score_defense().

  def play_result_from_chart
    @offensive_play = offense.offensive_play_strategy.choose
    @defensive_play = defense.defensive_play_strategy.choose
    result_chart = offense.play_result_chart
    result_chart.result(@offensive_play, @defensive_play)
  end

  def get_plays
    if down == 4
      Array(offense.offensive_play_strategy.choose_on_4th_down(self))
    else
      str_results = play_result_from_chart.split('_or_')
      str_results.map { |str_result| Play.parse(str_result) }
    end
  end

  def play(value=nil)
    value = nil if Game.next_plays.keys.include?(value)
    self.error_message = nil
    if kickoff?
      play = Play.kickoff
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
    if play.possession_changing?
      change_possesion(play.yardage)
    else
      yardage_play(play)
    end
  end

  private

    def toggle_possesion
      self.is_ball_to_home = !is_ball_to_home
      self.ball_on = 100 - ball_on
    end

    def firstdown
      self.down = 1
      self.yard_to_go = 10
    end

    def touchdown
      if is_ball_to_home
        self.score_home += 7
      else
        self.score_visitors += 7
      end
      firstdown
      self.ball_on = KICKOFF_YARDLINE
      self.next_play = :kickoff
    end

    def touchback
      self.ball_on = 100 - TOUCHBACK_YARDLINE
    end

    def yardage_play(play)
      self.ball_on += play.yardage
      if ball_on >= 100
        touchdown
      else
        self.yard_to_go -= play.yardage
        self.down += 1 if play.no_penalty?
        if yard_to_go <= 0 || play.auto_firstdown?
          firstdown
        elsif down > 4
          toggle_possesion
          firstdown
        end
      end
      self.time_left -= 40
    end

    def change_possesion(yard)
      self.ball_on += yard
      touchback if ball_on >= 100
      toggle_possesion
      firstdown
      self.time_left -= 10
    end
end
