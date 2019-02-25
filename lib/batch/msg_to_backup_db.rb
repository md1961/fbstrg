league = League.order(:updated_at).last
schedule = league.schedules.find_all { |s| s.game&.final? }.last
number = league.next_schedule&.week == schedule&.week ? "-#{schedule.number}" : ''
puts "DB backup (#{league.year} week #{schedule.week}#{number})"
