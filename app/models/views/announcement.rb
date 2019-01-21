module Views

class Announcement

  def initialize
    @statements = []
  end

  def add(text, time)
    @statements << Statement.new(text, time)
    self
  end

  def empty?
    @statements.empty?
  end

  def last_text
    @statements.last&.text
  end

  def to_s
    texts = @statements.map(&:text) + ['__END__']
    times = [0] + @statements.map(&:time)
    "[#{texts.zip(times).map { |text, time|
      %Q!["#{text}",#{time}]!
    }.join(',')}]"
  end

  class Statement
    attr_reader :text, :time

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
