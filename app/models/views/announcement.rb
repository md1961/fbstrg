module Views

class Announcement

  def initialize
    @statements = []
  end

  def add(text, time)
    @statements << Statement.new(text, time)
    self
  end

  def set_time_to_last(time)
    @statements.last.time = time unless empty?
    self
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

  def to_s(speed: nil)
    speed = 1 if speed.to_i.zero?
    texts = @statements.map(&:text) + ['__END__']
    times = [0] + @statements.map(&:time)
    "[#{texts.zip(times).map { |text, time|
      %Q!["#{text}",#{time / speed}]!
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
