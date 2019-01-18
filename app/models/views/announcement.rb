module Views

class Announcement

  def initialize
    @statements = []
  end

  def add(text, timeout)
    @statements << Statement.new(text, timeout)
    self
  end

  def empty?
    @statements.empty?
  end

  def last_text
    @statements.last&.text
  end

  def to_s
    "[#{@statements.join(',')}]"
  end

  class Statement
    attr_reader :text, :timeout

    def initialize(text, timeout)
      @text = text
      @timeout = timeout
    end

    def to_s
      %Q!["#{text}",#{timeout}]!
    end
  end
end

end
