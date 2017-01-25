class Play < ActiveRecord::Base
  enum result:  {on_ground: 0, complete: 1, incomplete: 2, intercepted: 3, sacked: 4}
  enum fumble:  {no_fumble: 0, fumble_rec_by_own: 1, fumble_rec_by_opponent: 2}
  enum penalty: {no_penalty: 0, off_penalty: 1, def_penalty: 2}
end
