class TeamGroup < ApplicationRecord
  has_many :teams
  belongs_to :parent, foreign_key: 'parent_id'
end
