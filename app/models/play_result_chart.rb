class PlayResultChart < ApplicationRecord
  has_many :play_results, dependent: :destroy

  def result(offensive_play, defensive_play)
    play_results.find_by(offensive_play: offensive_play, defensive_play: defensive_play).result
  end
end
