class OffensivePlay < ActiveRecord::Base
  has_many :play_results

  # Define methods such as OffensivePlay.power_up_middle, etc.
  class << self
    OffensivePlay.pluck(:name).each do |name|
      method_name = name.titleize.gsub(/[\s&]+/, '').underscore
      define_method method_name do
        instance_variable_get(:"@#{method_name}") \
          || instance_variable_set(:"@#{method_name}", find_by(name: name))
      end
    end
  end

  # Define methods such as OffensivePlay#power_up_middle?, etc.
  pluck(:name).each do |name|
    method_name = name.titleize.gsub(/[\s&]+/, '').underscore
    define_method "#{method_name}?" do
      self.name == name
    end
  end

  def normal?
    number < 100
  end

  def inside_10?
    number <= 12
  end

  def inside_20?
    number <= 16
  end

  def kickoff?
    name.ends_with?('Kickoff')
  end

  def punt?
    name.ends_with?('Punt')
  end

  def to_s
    normal? ? "#{number}. #{name}" : name
  end
end
