class PlayoffBerth < ApplicationRecord
  belongs_to :league, class_name: 'TeamGroup', foreign_key: 'team_group_id'
  belongs_to :team
end
