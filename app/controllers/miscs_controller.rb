class MiscsController < ApplicationController

  def index
    min, max = -10, 10
    @freq_dists = [
      FreqDist.new(9, 21, 100) { MathUtil.pick_from_decreasing_distribution(10, 20) },
      # FreqDist.new(min, max, 100) { 6.times.map { rand(-1 .. 1) }.sum },
      # FreqDist.new(min, max, 100) { 3.times.map { rand(-2 .. 2) }.sum },
      # FreqDist.new(min, max, 100) { 2.times.map { rand(-3 .. 3) }.sum },
    ]
  end

  class FreqDist
    attr_reader :min, :max

    def initialize(min, max, n, &f)
      @min = min
      @max = max
      @n = n
      @f = f
    end

    def h_freq
      @n.times.each_with_object(Hash.new(0)) { |_, h| h[@f.call] += 1 }
    end
  end
end
