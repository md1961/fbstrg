class TeamGroup < ApplicationRecord
  has_many :direct_teams, class_name: 'Team'
  belongs_to :parent, class_name: 'TeamGroup', foreign_key: 'parent_id', optional: true

  before_save :set_abbr

  def teams
    direct_teams
  end

  private

    def set_abbr
      return if abbr
      self.abbr = (name.split + [self.class.name]).map(&:first).join
    end
end
