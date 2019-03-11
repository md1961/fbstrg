class TeamGroup < ApplicationRecord
  has_many :direct_teams, class_name: 'Team'
  belongs_to :parent, foreign_key: 'parent_id', optional: true
end
