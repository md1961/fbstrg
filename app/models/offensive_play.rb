class OffensivePlay < ActiveRecord::Base
  has_many :play_results

  def self.punt
    @punt ||= find_by(name: 'Punt')
  end

  def self.field_goal
    @field_goal ||= find_by(name: 'Field Goal')
  end

  def punt?
    name == 'Punt'
  end

  def field_goal?
    name == 'Field Goal'
  end

  def to_s
    name
  end
end
