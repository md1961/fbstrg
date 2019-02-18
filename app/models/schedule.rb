class Schedule < ApplicationRecord
  belongs_to :team_group
  belongs_to :game

  def for?(team)
    game.for?(team)
  end

  def to_s
    "#{team_group} week #{week}: #{game}"
  end
end
