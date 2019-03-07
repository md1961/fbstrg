PRO_STYLE_RESULTS = [
  #%w(-2 -1 +10 +1 +1 +2 +3 +7 +9 +10),
  %w[-2..0 -1..1 8..12 -1..2 0..2 1..3 2..4 5..9 6..12 8..14],
  #%w(-1 0 -2 +3 +5 +7 +9 -1 +11 +14),
  %w[-2..0 -1..1 -2..3 2..4 4..6 5..9 7..11 -2..4 8..14 11..17],
  #%w(0 -1 +15 +2 +2 +2 -2 +15 +5 +5),
  %w[-1..1 -1..1 -1..10 -1..3 0..3 1..3 1..4 -1..10 3..8 4..10],
  #%w(0 +2 -3 +3 +4 +7 +8 -3 +13 +18),
  %w[-2..2 -1..3 -3..2 1..5 2..6 5..9 6..10 -3..3 10..16 15..22],

  #%w(-4 -1 0 +4 -3 +6 +9ob +2 +21ob +25ob),
  %w[-4..3 -4..6 -4..10 -4..4 3..10 5..13ob 7..15ob 0..12 12..24ob 15..30ob],
  #%w(-2 +1ob -4 0 +7 +10 +13ob -6 +20ob long),
  %w[-4..4 -4..7ob -6..6 -4..8 0..14 3..17 6..20ob -6..4 10..30ob 20..35ob],
  #%w(+1 +2 -2 +2 +10 -2 +5 -3 +12 +22),
  %w[-2..4 -1..5 -4..4 0..4 2..7 3..8 4..9 -4..6 6..18 12..26],
  #%w(+3 -1 +9 +4 +2 0 +4 +15 +9 +11),
  %w[0..5 -1..2 5..13 2..6 0..4 0..5 2..8 7..22 5..15 7..20],

  #%w(-5 cmp+13ob +5 incmp +20 incmp incmp cmp+25 +5 incmp),
  %w[-5 90%10..15ob 75%10..30 20%5..15 10..30 10%5..15 5%5..15 -5..15 -5..10 incmp],
  #%w(cmp+3 cmp+6 incmp cmp+5ob cmp+3ob cmp+1 incmp cmp-2 cmp+17ob cmp+4ob),
  %w[100%2..7 100%4..9 40%5..15 100%3..7ob 90%2..6ob 70%1..5 50%0..5 50%-2..4 100%10..20ob 100%10..20ob],
  #%w(cmp+14ob incmp incmp cmp+7ob cmp+5ob cmp+4ob cmp+3ob incmp incmp incmp),
  %w[100%10..20ob 100%5..15ob 50%7..14 90%5..10ob 85%3..7ob 80%2..6ob 75%1..5ob 50%5..20ob 80%5..20ob 90%5..20ob],
  #%w(cmp+9 incmp cmp+6 incmp incmp incmp cmp+11 cmp+6 cmp+4 cmp+5),
  %w[100%5..15 95%5..15 55%5..20 70%5..15 60%5..15 55%5..15 50%5..15 55%5..20 95%5..15 100%5..15],

  #%w(cmp+18 cmp+15 cmp+9 cmp+6 cmp+4ob cmp+3 incmp cmp+12 incmp incmp),
  %w[95%15..25 95%10..20 97%10..15 95%-2..8 90%-3..6 85%-4..5 80%-5..2 97%10..25 95%5..20 95%5..20],
  #%w(cmp+19 cmp+16 cmp+11 cmp+8 incmp incmp cmp+4 incmp incmp incmp),
  %w[100%15..25 100%10..20 45%5..20 85%5..15 75%5..15 65%5..15 55%5..10 45%5..20 75%10..20 80%10..20],
  #%w(cmp+16 cmp+13 cmp+8 incmp incmp cmp+16 incmp cmp+7 incmp cmp+12),
  %w[100%15..30 100%15..30 40%10..25 80%10..20 70%10..20 60%10..20 50%5..10 40%10..25 70%15..25 75%15..25],
  #%w(long long sck-15 +11ob -5 sck-10 sck-10 sck-15 long long),
  %w[80%15..30 80%15..30 sck-15 70%15..30 60%15..25 50%10..25 40%10..20 sck-15 80%5..20 80%5..20],

  #%w(cmp+50ob cmp+45ob cmp+35 cmp+25 incmp cmp+25 incmp incmp incmp incmp),
  %w[90%45..55ob 85%40..50ob 20%30..50 65%25..35 25%25..35 55%25..35 25%25..35 15%30..50 10%20..30 5%20..30],
  #%w(cmp+45 cmp+35 cmp+25 cmp+35 cmp+30 incmp incmp incmp incmp incmp),
  %w[90%40..50 90%30..40ob 20%20..45 70%20..30 60%20..30 30%20..30 25%20..30 15%30..45 10%15..30 5%15..30],
  #%w(cmp+long cmp+long cmp+30 cmp+35ob incmp incmp incmp incmp incmp incmp),
  %w[85%50..60 80%50..60 15%40..50 60%30..40 50%30..40 35%30..40 20%30..40 10%30..50 5%30..40 incmp],
  #%w(cmp+35 cmp+30 incmp incmp incmp incmp cmp+35ob cmp+30ob incmp incmp),
  %w[90%30..40 90%25..35 15%20..40 30%15..35 25%15..35 70%15..35 75%15..35 20%20..40 10%15..25 5%15..25],
]

STDOUT.puts "Creating PlayResultChart 'Pro style (revised)'..."

result_chart = PlayResultChart.find_or_create_by!(name: 'Pro style (revised)')
result_chart.play_results.destroy_all

defensive_plays = DefensivePlay.order(:name)
num_results = defensive_plays.size
PRO_STYLE_RESULTS.zip(OffensivePlay.order(:number)) do |row, offensive_play|
  STDOUT.puts "  for OffensivePlay '#{offensive_play.number}'..."
  STDOUT.flush
  raise "Number of results must be #{num_results} (#{row.size})" unless row.size == num_results
  row.zip(defensive_plays) do |result, defensive_play|
    begin
      Play.parse_result(result)
    rescue Exceptions::IllegalResultStringError => e
      raise "#{e} for '#{offensive_play}' x '#{defensive_play}'"
    end
    result_chart.play_results.create!(offensive_play: offensive_play, defensive_play: defensive_play, result: result)
  end
end

