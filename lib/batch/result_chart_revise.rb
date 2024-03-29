exit

PRO_STYLE_RESULTS = [
  %w[-2..0       -1..1       5..9       -1..2      0..2      1..3      2..4      8..12      6..12       8..14],
  %w[-2..0       -1..1       -2..3      2..4       4..6      5..9      7..11     -2..5      8..14       11..17],
  %w[-1..1       -1..1       -1..7      -1..3      0..3      1..3      1..4      -1..10     3..8        4..10],
  %w[-2..2       -1..3       -3..2      1..5       2..6      5..9      6..10     -3..4      10..16      15..22],

  %w[-4..3       -4..6       -4..10     -4..4      3..10     5..13ob   7..15ob   0..12      12..24ob    15..30ob],
  %w[-4..4       -4..7ob     -6..5      -4..8      0..14     3..17     6..20ob   -6..6      10..20ob    13..25ob],
  %w[-2..4       -1..5       -4..4      0..4       2..7      3..8      4..9      -4..8      6..18       12..26],
  %w[0..5        -1..2       5..13      2..6       0..4      0..5      2..8      7..22      5..15       7..20],

  %w[90%5..25    85%5..25    30%5..30   70%5..25   60%5..25  40%5..25  35%5..25  25%5..30   20%5..20    10%5..20],
  %w[95%2..7     90%4..9     55%-2..9   85%3..7ob  80%2..6ob 75%1..5   65%0..5   50%5..15   70%10..20ob 75%10..20ob],
  %w[95%10..20ob 90%5..15ob  50%3..14   80%5..10ob 75%3..7ob 70%2..6ob 60%1..5ob 45%6..20ob 60%5..20ob  70%5..20ob],
  %w[90%5..15    85%5..15    45%5..17   75%5..15   70%5..15  60%5..15  50%5..15  40%7..22   70%5..15    75%5..15],

  %w[97%15..25   97%10..20   95%10..15  97%-2..8   90%-3..6  85%-4..5  80%-5..2  95%10..25  97%5..20    97%5..20],
  %w[85%15..25   80%10..20   40%5..20   70%5..15   60%5..15  55%5..15  45%5..10  35%5..20   40%10..20   45%10..20],
  %w[80%15..30   75%15..30   35%10..25  55%10..20  45%10..20 60%8..15  50%5..10  30%10..25  40%15..25   45%15..25],
  %w[75%15..35   70%15..35   30%10..30  60%10..25  50%10..25 45%10..25 35%5..15  25%10..30  35%15..30   40%15..30],

  %w[70%45..55ob 65%40..50ob 20%30..50  50%25..35  25%25..35 40%25..35 25%25..35 15%30..50  10%20..30   5%20..30],
  %w[70%40..50   65%30..40ob 20%20..45  55%20..30  50%20..30 30%20..30 25%20..30 15%30..45  10%15..30   5%15..30],
  %w[65%50..60   60%50..60   15%40..50  45%30..40  40%30..40 35%30..40 20%30..40 10%30..50  5%30..40    incmp],
  %w[70%30..40   65%25..35   15%20..40  30%15..35  25%15..35 55%15..35 50%15..35 20%20..40  10%15..25   5%15..25],

  %w[80%15..30   80%15..30   sck-15     70%15..30  60%15..25 50%10..25 40%10..20 sck-15     80%5..20    80%5..20],
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
