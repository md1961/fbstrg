class Team < ApplicationRecord
  belongs_to :team_group, optional: true
  belongs_to :play_result_chart
  belongs_to :offensive_strategy
  belongs_to :defensive_strategy
  has_one :team_trait, dependent: :destroy

  def human_assisted?
    name == 'Miami'
  end

  def league
    raise "Implement same as Schedule#league()" unless team_group.nil? || team_group.is_a?(League)
    team_group
  end

  def year
    league&.year
  end

  def won_lost_tied_pf_pa
    league.won_lost_tied_pf_pa_for(self)
  end

  def to_s
    name
  end
end
