class Team < ApplicationRecord
  belongs_to :team_group, optional: true
  belongs_to :play_result_chart
  belongs_to :offensive_strategy
  belongs_to :defensive_strategy
  has_one :team_trait, dependent: :destroy

  before_validation :set_strategies_and_traits, on: :create

  validates :name, presence: true
  validates :abbr, presence: true

  def human_assisted?
    name == 'Miami' || %w[H].include?(abbr)
  end

  def league
    return team_group if team_group.nil? || team_group.is_a?(League)
    team_group.league
  end

  def conference
    return nil if team_group.is_a?(League)
    return team_group if team_group.nil? || team_group.is_a?(Conference)
    team_group.conference
  end

  def year
    league&.year
  end

  def team_record
    league.team_record_for(self)
  end

  def to_s
    name
  end

  private

    def set_strategies_and_traits
      self.play_result_chart_id  = 2
      self.offensive_strategy_id = 1
      self.defensive_strategy_id = 1
      self.team_trait = TeamTrait.new
    end
end
