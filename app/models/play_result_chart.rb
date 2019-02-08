class PlayResultChart < ApplicationRecord
  has_many :play_results, dependent: :destroy

  after_find :init

  def init
    @results = {}
    @min_and_max_yardages = {}
  end

  def result(offensive_play, defensive_play)
    @results[[offensive_play.id, defensive_play.id]] ||= \
      play_results.find_by(offensive_play: offensive_play, defensive_play: defensive_play).result
  end

  def min_yardage(offensive_play)
    min_and_max_yardages(offensive_play)[0]
  end

  def max_yardage(offensive_play)
    min_and_max_yardages(offensive_play)[1]
  end

  private

    def min_and_max_yardages(offensive_play)
      @min_and_max_yardages[offensive_play.id] ||= \
        DefensivePlay.all.each_with_object([999, -999]) { |defensive_play, min_and_max|
          r = result(offensive_play, defensive_play)
          next if r !~ /[+-]?\d+/
          yardage = r.sub(/[^+-]*([+-]?\d+).*/, '\1').to_i
          min_and_max[0] = yardage if yardage < min_and_max[0]
          min_and_max[1] = yardage if yardage > min_and_max[1]
        }
    end
end
