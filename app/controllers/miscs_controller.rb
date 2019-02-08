class MiscsController < ApplicationController

  def index
    @freq_dists = [
      FreqDist.new(-6, 6, 100) { 6.times.map { rand(-1 .. 1) }.sum },
      FreqDist.new(-6, 6, 100) { 3.times.map { rand(-2 .. 2) }.sum },
      FreqDist.new(-6, 6, 100) { 2.times.map { rand(-3 .. 3) }.sum },
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
