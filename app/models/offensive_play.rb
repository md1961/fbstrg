class OffensivePlay < ActiveRecord::Base
  has_many :play_results

  NAMES_FOR_AUTO_DEF = OffensivePlay.where('number > 100').pluck(:name)

  class << self
    NAMES_FOR_AUTO_DEF.each do |name|
      method_name = name.titleize.gsub(/\s+/, '').underscore
      define_method method_name do
        instance_variable_get(:"@#{method_name}") \
          || instance_variable_set(:"@#{method_name}", find_by(name: name))
      end
    end
  end

  NAMES_FOR_AUTO_DEF.each do |name|
    method_name = name.titleize.gsub(/\s+/, '').underscore
    define_method "#{method_name}?" do
      self.name == name
    end
  end

  def normal?
    number < 100
  end

  def to_s
    normal? ? "#{number}. #{name}" : name
  end
end
