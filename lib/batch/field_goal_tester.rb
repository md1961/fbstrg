# ball_on is 1 .. 99
def fg_good?(ball_on)
  play_yardage = rand(0..100)
  fg_yardage = 100 - ball_on + 10 + 7
  y_adjust = [fg_yardage - 50, 0].max * 2

  play_yardage >= 100 - ball_on + y_adjust
end

ys = [18, 30, 40, 50, 52, 54, 56, 58, 60]

puts \
  ys.zip(
    ys.map { |y|
      100 - (y - 17)
    }.map { |ball_on|
      1000.times.map { fg_good?(ball_on) }.count(&:itself)
    }
  ).map { |y, s| [y, s / 10.0].join(' => ') }
