require 'test_helper'

class PlaySetToolTest < ActiveSupport::TestCase
  include PlaySetTool

  test "#pick_from()" do
    weightables = 10.times.map { |id| Weightable.new(id, 100) }
    h_freq = 10000.times.inject(Hash.new { |h, k| h[k] = 0 }) do |h, i|
      h[pick_from(weightables).id] += 1
      h
    end
    10.times do |i|
      assert_in_delta(1000, h_freq[i], 100)
    end
  end

  class Weightable
    attr_accessor :id, :weight

    def initialize(id, weight)
      @id     = id
      @weight = weight
    end
  end
end
