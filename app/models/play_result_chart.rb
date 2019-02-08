class PlayResultChart < ApplicationRecord
  has_many :play_results, dependent: :destroy

  after_find :init

  def init
    @results = {}
  end

  def result(offensive_play, defensive_play)
    @results[[offensive_play.id, defensive_play.id]] ||= \
      play_results.find_by(offensive_play: offensive_play, defensive_play: defensive_play).result
  end
end
