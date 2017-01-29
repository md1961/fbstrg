class OffensivePlay < ActiveRecord::Base
  has_many :play_results

  # TODO: Define all by one statement.

  def self.kickoff
    @kickoff ||= find_by(name: 'Kickoff')
  end

  def self.punt
    @punt ||= find_by(name: 'Punt')
  end

  def self.field_goal
    @field_goal ||= find_by(name: 'Field Goal')
  end

  def self.extra_point
    @extra_point ||= find_by(name: 'Extra Point')
  end

  def kickoff?
    name == 'Kickoff'
  end

  def punt?
    name == 'Punt'
  end

  def field_goal?
    name == 'Field Goal'
  end

  def extra_point?
    name == 'Extra Point'
  end

  def normal?
    number < 100
  end

  def to_s
    normal? ? "#{number}. #{name}" : name
  end
end
