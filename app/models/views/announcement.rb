module Views

class Announcement
  include FieldVision::Helper

  def initialize
    @statements = []
    @config = FieldVision::Config.new
  end

  def add(text, time)
    @statements << Statement.new(text, time)
    self
  end

  def set_time_to_last(time)
    @statements.last.time = time unless empty?
    self
  end

  def add_time_to_last(time)
    @statements.last.time += time unless empty?
    self
  end

  def fly_ball_marker(play, game, time: 0)
    sign_direction = game.home_has_ball ? 1 : -1
    sign_direction *= -1 if play.possession_changed?
    x_move = yard_in_px(play.air_yardage) * sign_direction
    color = 'null'

    add("FLY: #{x_move} #{color}", time)
  end

  def hold_ball_marker_for_field_goal(play, game, time: 0)
    sign_direction = game.home_has_ball ? 1 : -1
    sign_direction *= -1 if play.possession_changed?
    x_move = yard_in_px(-7) * sign_direction
    color = 'null'

    add("FLY: #{x_move} #{color}", time)
  end

  def show_ball_marker(yard, is_home_team: true, color: 'null', time: 0)
    return unless yard
    add("BALL: #{yard} #{is_home_team} #{color}", time)
  end

  def empty?
    @statements.empty?
  end

  def last_text
    @statements.last&.text
  end

  def total_time_in_sec
    (@statements.map(&:time).sum / 1000.0).ceil - 1
  end

  MINIMUM_TIME = 200

  def to_s(speed: nil)
    speed = 1 if speed.to_i.zero?
    texts = @statements.map(&:text) + ['__END__']
    times = [0] + @statements.map(&:time)
    "[#{texts.zip(times).map { |text, time|
      %Q!["#{text}",#{[time, MINIMUM_TIME].max / speed}]!
    }.join(',')}]"
  end

  class Statement
    attr_reader :text
    attr_accessor :time

    def initialize(text, time)
      @text = text
      @time = time
    end

    def to_s
      %Q!["#{text}",#{time}]!
    end
  end
end

end
