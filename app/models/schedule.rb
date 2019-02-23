class Schedule < ApplicationRecord
  include Comparable

  belongs_to :team_group
  belongs_to :game

  def for?(team)
    game.for?(team)
  end

  def next?
    self == league&.next_schedule
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
    "#{team_group} week #{week}: #{game.to_s(optional_strs)}"
  end
end
