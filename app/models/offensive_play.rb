class OffensivePlay < ActiveRecord::Base
  has_many :play_results

  def to_s
    name
  end
end
