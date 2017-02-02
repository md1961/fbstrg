require 'test_helper'

class OffensivePlaySetTest < ActiveSupport::TestCase

  setup do
    @play_set = offensive_play_sets(:standard)
    @game = games(:one)
  end

  def count_freq(total_counts)
    total_counts.times.inject(Hash.new { |h, k| h[k] = 0 }) do |h, i|
      play = @play_set.choose(@game)
      h[play.number] += 1
      return h if yield(h)
      h
    end
  end

  test '#choose for full play choice' do
    @game.ball_on = 1
    h_freq = count_freq(1000) { |h| h.keys.size >= 20 }
    assert_equal((1 .. 20).to_a, h_freq.keys.map(&:to_i).sort)

    @game.ball_on = 79
    h_freq = count_freq(1000) { |h| h.keys.size >= 20 }
    assert_equal((1 .. 20).to_a, h_freq.keys.map(&:to_i).sort)
  end

  test '#choose for play choice limitation inside 20 yard' do
    @game.ball_on = 80
    h_freq = count_freq(1000) { |h| h.keys.size >= 16 }
    assert_equal((1 .. 16).to_a, h_freq.keys.map(&:to_i).sort)

    @game.ball_on = 89
    h_freq = count_freq(1000) { |h| h.keys.size >= 16 }
    assert_equal((1 .. 16).to_a, h_freq.keys.map(&:to_i).sort)
  end

  test '#choose for play choice limitation inside 10 yard' do
    @game.ball_on = 90
    h_freq = count_freq(1000) { |h| h.keys.size >= 12 }
    assert_equal((1 .. 12).to_a, h_freq.keys.map(&:to_i).sort)

    @game.ball_on = 99
    h_freq = count_freq(1000) { |h| h.keys.size >= 12 }
    assert_equal((1 .. 12).to_a, h_freq.keys.map(&:to_i).sort)
  end
end
