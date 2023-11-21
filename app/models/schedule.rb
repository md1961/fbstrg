class Schedule < ApplicationRecord
  include Comparable

  belongs_to :team_group
  belongs_to :game

  scope :regulars, -> { where(is_playoff: false) }
  scope :playoffs, -> { where(is_playoff: true ) }

  def for?(team)
    game.for?(team)
  end

  def league
    group = team_group
    while !group.is_a?(League)
      group = group.parent
    end
    group
  end

  def <=>(other)
    return nil unless other
    [week, number] <=> [other.week, other.number]
  end

  def to_s(optional_strs = {})
    "Week #{week} ##{number}: #{game.to_s(optional_strs)}"
  end
end
