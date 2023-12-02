require 'test_helper'

class DefensivePlayTest < ActiveSupport::TestCase
  test ".pick_from()" do
    %w[a j abcd fgij ac ah gc gh].each do |names|
      assert_nothing_raised do
        DefensivePlay.pick_from(names)
      end
    end

    %w[k abdef efgij ci cj hi hj].each do |names|
      assert_raises(Exceptions::IllegalResultStringError) do
        DefensivePlay.pick_from(names)
      end
    end
  end
end
