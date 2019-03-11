class TeamGroup < ApplicationRecord
  has_many :direct_teams, class_name: 'Team'
  has_many :child_groups, class_name: 'TeamGroup', foreign_key: 'parent_id'
  belongs_to :parent    , class_name: 'TeamGroup', foreign_key: 'parent_id', optional: true

  before_save :set_abbr

  def teams
    return direct_teams unless direct_teams.empty?
    child_groups.flat_map(&:teams)
  end

  private

    def set_abbr
      return if abbr
      self.abbr = (name.split + [self.class.name]).map(&:first).join
    end
end
