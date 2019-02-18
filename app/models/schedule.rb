class Schedule < ApplicationRecord
  belongs_to :team_group
  belongs_to :game

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

  def to_s
    "#{team_group} week #{week}: #{game}"
  end
end
