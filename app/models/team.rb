class Team < ApplicationRecord
  belongs_to :team_group, optional: true
  belongs_to :play_result_chart
  belongs_to :offensive_strategy
  belongs_to :defensive_strategy
  has_one :team_trait, dependent: :destroy

  def to_s
    name
  end
end
