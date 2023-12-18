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

  def next_in_same_week
    return nil unless league

    league.schedules.find_by(week: week, number: number + 1)
  end

  def postpone
    return unless next_in_same_week

    self.class.transaction do
      next_in_same_week.update!(number: number    )
      self             .update!(number: number + 1)
    end
  end

  def <=>(other)
    return nil unless other
    [week, number] <=> [other.week, other.number]
  end

  def to_s(optional_strs = {})
    "Week #{week} ##{number}: #{game.to_s(optional_strs)}"
  end
end
