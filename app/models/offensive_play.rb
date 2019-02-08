class OffensivePlay < ApplicationRecord
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

  scope :normal_plays, -> { where("number < 100") }
  scope :pass_plays  , -> { where.not(max_throw_yard: nil) }

  def run?
    number <= 8
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

  # TODO: Do not rely on OffensivePlay#number.
  def hard_to_go_out_of_bounds?
    [1, 2, 3, 4, 7, 8, 9].include?(number)
  end
  def easy_to_go_out_of_bounds?
    [5, 6, 10, 11, 13, 17].include?(number)
  end

  def short_pass?
    max_throw_yard && max_throw_yard < 11
  end

  def medium_pass?
    max_throw_yard && max_throw_yard.between?(11, 20)
  end

  def long_pass?
    max_throw_yard && max_throw_yard > 20
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
