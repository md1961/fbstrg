class Play < ActiveRecord::Base
  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4}
  enum fumble:  {no_fumble: 0, by_own: 1, by_opponent: 2}
  enum penalty: {no_penalty: 0, by_offense: 1, by_defense: 2}
end
